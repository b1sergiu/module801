GAME = "shepherd"

prochaineSeconde = 0

function eventMessageReceive(joueur, id, msg)
	if joueur.room == nil then
		return
	end
	-- Maj curseur
	if id == 2 then
		if joueur.room.berger == joueur then
			joueur.room.sendExcept(joueur, 2, msg[0], msg[1])
		end
		return
	end
	-- Synchronisation
	if id == 4 then
		if joueur.room.codePartieEnCours == msg[0] then
			joueur.direction = msg[1];
			joueur.posX = msg[2];
			joueur.posY = msg[3];
			joueur.vitesseX = msg[4];
			joueur.vitesseY = msg[5];
			joueur.room.sendExcept(joueur, 4, joueur.name, joueur.direction, joueur.posX, joueur.posY, joueur.vitesseX, joueur.vitesseY)
			if joueur.direction > 0 then
				joueur.estAfk = false
			end
			-- Distance
			local temps = os.time()
			local distance = math.abs(joueur.posX - joueur.dernierePosX)
			local tempsEcoule = temps - joueur.tempsDernierePosX
			local vitesse = distance / tempsEcoule / 1000
			if vitesse / joueur.vitesse > 1.2 then
				joueur.anomalies = joueur.anomalies + 1
			else
				joueur.anomalies = 0
			end
			if joueur.anomalies >= 2 then
				joueur.mortAuto = true;
			end
			joueur.dernierePosX = joueur.posX
			joueur.tempsDernierePosX = temps
		end
		return
	end
	-- Mort d'un joueur
	if id == 6 then
		if joueur.room.codePartieEnCours == msg[0] then
			mortJoueur(joueur, msg[1])
		end
		return
	end
	-- Déclenchement d'un piège
	if id == 7 then
		if joueur.room.codePartieEnCours == msg[0] then
			if joueur.room.berger == joueur then
				joueur.room.send(7, msg[1], msg[2])
			end
		end
		return
	end
	-- Protection
	if id == 8 then
		joueur.room.sendExcept(joueur, 8, joueur.name)
		return
	end
end

function mortJoueur(joueur, codePiege)
	if not joueur.estMort then
		if joueur.mortAuto then
			codePiege = 0
		end
		joueur.estMort = true
		joueur.room.send(6, joueur.name, codePiege)
		joueur.room.joueurEnVie = joueur.room.joueurEnVie - 1
		-- Le joueur gagne
		if codePiege == 44 then
			joueur.point = joueur.point + 1
			joueur.room.send(3, joueur.name, joueur.point)
		end
		if joueur.room.joueurEnVie <= 0 then
			finirPartie(joueur.room)
		end
	end
end

function eventPlayerConnected(joueur)
	joueur.changeRoom()
end

function eventRoomCreated(salon)
	salon.mondeEnCours = 1
	salon.codePartieEnCours = 0
	salon.joueurEnVie = 0
	salon.tempsDebutPartie = 0
	salon.tempsFinPartie = 0
	salon.antiAfkRequis = false
	salon.setMaxPlayer(50)
end

function eventPlayerJoinRoom(joueur, salon)
	joueur.send(37, salon.name)
	joueur.berger = false
	joueur.point = 0
	joueur.estMort = true
	joueur.estAfk = false
	joueur.posX = 50
	joueur.posY = 300
	joueur.vitesse = 1;
	joueur.anomalies = 0
	joueur.dernierePosX = 50;
	joueur.tempsDernierePosX = os.time()
	joueur.send(5, salon.mondeEnCours)
	for vieuxNomJoueur, vieuxJoueur in pairs(salon.playerList) do
		joueur.send(10, vieuxNomJoueur, vieuxJoueur.estMort, vieuxJoueur.posX, vieuxJoueur.posY)
	end
	salon.sendExcept(joueur, 10, joueur.name, joueur.estMort, joueur.posX, joueur.posY)
	if salon.berger ~= nil then
		joueur.send(39, salon.berger.name, salon.joueurEnVie)
	end
	-- Temps restant
	joueur.send(38, salon.tempsFinPartie - os.time())
	-- Nouvelle partie
	if salon.getPlayerCount() <= 2 then
		nouvellePartie(salon)
	end
end

-- Nouvelle partie
function nouvellePartie(salon)
	salon.tempsDebutPartie = os.time()
	salon.tempsFinPartie = salon.tempsDebutPartie + 40000
	salon.codePartieEnCours = (salon.codePartieEnCours + 1) % 10
	salon.antiAfkRequis = true
	if salon.berger ~= nil then
		salon.berger.point = 0
		salon.send(3, salon.berger.name, 0)
	end
	local nouveauBerger
	salon.send(5, salon.mondeEnCours, salon.codePartieEnCours)
	local nombreBergerPossible = 0
	local listeBergerPossible = {}
	local meilleurScore = 0
	-- Respawn des joueurs
	for nomJoueur, joueur in pairs(salon.playerList) do
		joueur.posX = 50
		joueur.dernierePosX = 50
		joueur.anomalies = 0
		joueur.tempsDernierePosX = salon.tempsDebutPartie
		joueur.posY = 300
		joueur.estMort = false
		joueur.mortAuto = false;
		joueur.estAfk = true
		joueur.vitesse = 40 + math.floor(math.random() * 30)
		salon.send(9, nomJoueur, joueur.posX, joueur.posY, joueur.vitesse)
		-- Selection du berger
		if joueur.point == meilleurScore then
			listeBergerPossible[nombreBergerPossible] = joueur
			nombreBergerPossible = nombreBergerPossible + 1
		elseif joueur.point > meilleurScore then
			meilleurScore = joueur.point
			listeBergerPossible = {}
			listeBergerPossible[0] = joueur
			nombreBergerPossible = 1
		end
		if joueur == salon.prochainBerger then
			nouveauBerger = joueur
		end
	end
	if nombreBergerPossible > 0 and nouveauBerger == nil then
		nouveauBerger = listeBergerPossible[math.floor(math.random() * nombreBergerPossible)]
	end
	salon.prochainBerger = nil
	salon.berger = nouveauBerger
	salon.joueurEnVie = salon.getPlayerCount()
	-- Initialisation des pièges
	if nouveauBerger ~= nil then
		nouveauBerger.estAfk = false
		local codePiege
		salon.joueurEnVie = salon.joueurEnVie - 1
		-- On envoie le nom du berger aux autres joueurs
		salon.send(39, nouveauBerger.name, salon.joueurEnVie)
		-- Pièges du haut
		for i = 0, 3, 1 do
			codePiege = math.floor(math.random() * 4)
			nouveauBerger.send(40, i, codePiege)
		end
		-- Pièges du bas
		for i = 4, 7, 1 do
			codePiege = 20 + math.floor(math.random() * 4)
			nouveauBerger.send(40, i, codePiege)
		end
	end

	-- Temps restant
	salon.send(38, salon.tempsFinPartie - salon.tempsDebutPartie)
end

function finirPartie(salon)
	local temps = os.time()
	local tempsRestant = salon.tempsFinPartie - temps
	if tempsRestant > 5000 then
		salon.tempsFinPartie = temps + 5000
		salon.send(38, 5000)
	end
end

function eventPlayerLeaveRoom(joueur, salon)
	salon.send(11, joueur.name)
end

function eventPlayerDisconnected(joueur)
end

function eventLoop(temps)
	if temps > prochaineSeconde then
		prochaineSeconde = temps + 1000
		-- Boucle
		for nomSalon, salon in pairs(m801.get.roomList) do
			-- Anti-afk
			if salon.antiAfkRequis then
				local tempsEcoule = temps - salon.tempsDebutPartie
				if tempsEcoule > 10000 then
					salon.antiAfkRequis = false
					for nomJoueur, joueur in pairs(salon.playerList) do
						if joueur.estAfk then
							mortJoueur(joueur, 33)
						end
					end
				end
			end
			-- Nouvelle partie
			if temps > salon.tempsFinPartie then
				nouvellePartie(salon)
			elseif salon.joueurEnVie <= 0 and salon.getPlayerCount() > 1 then
				finirPartie(salon)
			end
		end
	end
end