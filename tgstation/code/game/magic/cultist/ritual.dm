var/wordtravel = null
var/wordself = null
var/wordsee = null
var/wordhell = null
var/wordblood = null
var/wordjoin = null
var/wordtech = null
var/worddestr = null
var/wordother = null
var/wordhide = null
var/runedec = 0
var/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/cultwords = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")



/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning"
	if(!wordtravel)
		runerandom()
	usr << "[wordtravel] is travel, [wordblood] is blood, [wordjoin] is join, [wordhell] is Hell, [worddestr] is destroy, [wordtech] is technology, [wordself] is self, [wordsee] is see, [wordother] is other, [wordhide] is hide."


/proc/runerandom() //randomizes word meaning
	var/list/runewords=list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")
	wordtravel=pick(runewords)
	runewords-=wordtravel
	wordself=pick(runewords)
	runewords-=wordself
	wordsee=pick(runewords)
	runewords-=wordsee
	wordhell=pick(runewords)
	runewords-=wordhell
	wordblood=pick(runewords)
	runewords-=wordblood
	wordjoin=pick(runewords)
	runewords-=wordjoin
	wordtech=pick(runewords)
	runewords-=wordtech
	worddestr=pick(runewords)
	runewords-=worddestr
	wordother=pick(runewords)
	runewords-=wordother
	wordhide=pick(runewords)
	runewords-=wordhide



//teleport, gate, tome, convert, terror, emp, drain, clarity, raise
//obscure, scry, manifest, seal, sacrifice, reveal, wall, freedom
//summon, deafen, blind, bloodboil, contact, explode, hold

/obj/rune
	desc = ""
	anchored = 1
	icon = 'rune.dmi'
	icon_state = "1"
	var/visibility = 0
	unacidable = 1
	layer = TURF_LAYER


	var
		runetype
		word1
		word2
		word3


	CanPass(atom/movable/O, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1
		if(!O)
			return 0
		if(src.runetype == "wall")
			if(istype(O, /mob))
				if (iscultist(O))
					return 1
				else
					return !src.density
		if(istype(O, /obj))
			return 1
		return !src.density


	examine()
		if(!iscultist(usr))
			usr << "A strange collection of symbols drawn in blood."
			if(desc && !usr.stat)
				usr << "It reads: <i>[desc]</i>."
				sleep(30)
				explosion(src.loc, 0, 2, 5, 5)
				if(src)
					del(src)
		else
			if(!desc)
				usr << "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."
			else
				usr << "Explosive Runes inscription in blood. It reads: <i>[desc]</i>."

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/tome) && iscultist(user))
			user << "You retrace your steps, carefully undoing the lines of the rune."
			del(src)
			return
		else if(istype(I, /obj/item/weapon/storage/bible) && usr.mind && (usr.mind.assigned_role == "Chaplain"))
			var/obj/item/weapon/storage/bible/bible = I
			user << "\blue You banish the vile magic with the blessing of [bible.deity_name]!"
			del(src)
			return
		return

	attack_hand(mob/user as mob)
		if(!iscultist(user))
			user << "You can't mouth the arcane scratchings without fumbling over them."
			return
		if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle) || user.ear_deaf)
			user << "You need to be able to both speak and hear to use runes."
			return
		if(!word1 || !word2 || !word3 || !runetype || prob(usr.brainloss))
			return fizzle()
		switch(runetype) //call �� ������� usr. �������, � ��������.
			if("teleport")
				teleport(word3)
			if("gate")
				gate(word3)
			if("tome")
				tome()
			if("convert")
				convert()
			if("terror")
				terror()
			if("emp")
				emp(src.loc,1)
			if("drain")
				drain()
			if("truesight")
				truesight()
			if("raise")
				raise()
			if("obscure")
				obscure()
			if("scry")
				scry()
			if("manifest")
				manifest()
			if("seal")
				seal()
			if("sacrifice")
				sacrifice()
			if("reveal")
				reveal(src)
			if("wall")
				wall()
			if("freedom")
				freedom()
			if("summon")
				summon()
			if("deafen")
				deafen()
			if("blind")
				blind()
			if("bloodboil")
				bloodboil()
			if("contact")
				contact()
			if("explode")
				explode()
			if("hold")
				hold()
		return

	proc
		fizzle()
			if(istype(src,/obj/rune))
				usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			else
				usr.whisper(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return
//teleport, gate, tome, convert, terror, emp, drain, clarity, raise
//obscure, scry, manifest, seal, sacrifice, reveal, wall, freedom
//summon, deafen, blind, bloodboil, contact, explode, hold

		check_words()
			if(word1 == wordtravel && word2 == wordself)
				runetype = "teleport"
				return
			if(word1 == wordtravel && word2 == wordother)
				runetype = "gate"
				return
			if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
				runetype = "tome"
				return
			if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
				runetype = "convert"
				return
			if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
				runetype = "terror"
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
				runetype = "emp"
				return
			if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
				runetype = "drain"
				return
			if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)
				runetype = "truesight"
				return
			if(word1 == wordblood && word2 == wordjoin && word3 == wordhell)
				runetype = "raise"
				return
			if(word1 == wordhide && word2 == wordsee && word3 == wordblood)
				runetype = "obscure"
				return
			if(word1 == wordhell && word2 == wordtravel && word3 == wordself)
				runetype = "scry"
				return
			if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
				runetype = "manifest"
				return
			if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
				runetype = "seal"
				return
			if(word1 == wordhell && word2 == wordblood && word3 == wordjoin)
				runetype = "sacrifice"
				return
			if(word1 == wordblood && word2 == wordsee && word3 == wordhide)
				runetype = "reveal"
				return
			if(word1 == worddestr && word2 == wordtravel && word3 == wordself)
				runetype = "wall"
				return
			if(word1 == wordtravel && word2 == wordtech && word3 == wordother)
				runetype = "freedom"
				return
			if(word1 == wordjoin && word2 == wordother && word3 == wordself)
				runetype = "summon"
				return
			if(word1 == wordhide && word2 == wordother && word3 == wordsee)
				runetype = "deafen"
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordother)
				runetype = "blind"
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordblood)
				runetype = "bloodboil"
				return
			if(word1 == wordself && word2 == wordother && word3 == wordtech)
				runetype = "contact"
				return
			if(word1 == wordblood && word2 == worddestr && word3 == wordhell)
				runetype = "explode"
				return
			if(word1 == wordtravel && word2 == worddestr)
				runetype = "hold"
				return
			check_icon()

		check_icon()
			switch(runetype)
				if("teleport")
					icon_state = "2"
					src.icon += rgb(0, 0 , 255)
				if("gate")
					icon_state = "1"
					src.icon += rgb(200, 0, 0)
				if("tome")
					icon_state = "5"
					src.icon += rgb(0, 0 , 255)
				if("convert")
					icon_state = "3"
				if("terror")
					icon_state = "4"
				if("emp")
					icon_state = "5"
				if("drain")
					icon_state = "2"
				if("clarity")
					icon_state = "4"
					src.icon += rgb(0, 0 , 255)
				if("raise")
					icon_state = "1"
				if("obscure")
					icon_state = "1"
					src.icon += rgb(0, 0 , 255)
				if("scry")
					icon_state = "6"
					src.icon += rgb(0, 0 , 255)
				if("manifest")
					icon_state = "6"
				if("seal")
					icon_state = "3"
					src.icon += rgb(0, 0 , 255)
				if("sacrifice")
					icon_state = "[rand(1,6)]"
					src.icon += rgb(255, 255, 255)
				if("reveal")
					icon_state = "4"
					src.icon += rgb(255, 255, 255)
				if("wall")
					icon_state = "1"
					src.icon += rgb(255, 0, 0)
				if("freedom")
					icon_state = "4"
					src.icon += rgb(255, 0, 255)
				if("summon")
					icon_state = "2"
					src.icon += rgb(0, 255, 0)
				if("deafen")
					icon_state = "4"
					src.icon += rgb(0, 255, 0)
				if("blind")
					icon_state = "4"
					src.icon += rgb(0, 0, 255)
				if("bloodboil")
					icon_state = "4"
					src.icon += rgb(255, 0, 0)
				if("contact")
					icon_state = "3"
					src.icon += rgb(200, 0, 0)
				if("explode")
					icon_state = "6"
					src.icon += rgb(200, 0, 200)
				if("hold")
					icon_state = "3"
				else //runetype not set or different
					icon_state="[rand(1,6)]" //random shape and color for dummy runes
					src.icon -= rgb(255,255,255)
					src.icon += rgb(rand(1,255),rand(1,255),rand(1,255))



/obj/item/weapon/tome
	name = "arcane tome"
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")

	tomedat = {"<html>
				<head>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood.</h1>

				<i>The book is written in an unknown dialect, there are lots of pictures of various complex geometric shapes. You find some notes in english that give you basic understanding of the many runes written in the book. The notes give you an understanding what the words for the runes should be. However, you do not know how to write all these words in this dialect.</i><br>
				<i>Below is the summary of the runes.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Teleport self: </b>Travel Self (word)<br>
				<b>Teleport other: </b>Travel Other (word)<br>
				<b>Summon new tome: </b>See Blood Hell<br>
				<b>Convert a person: </b>Join Blood Self<br>
				<b>Tear Reality: </b>Hell Join Self<br>
				<b>Disable technology: </b>Destroy See Technology<br>
				<b>Drain blood: </b>Travel Blood Self<br>
				<b>Raise dead: </b>Blood Join Hell<br>
				<b>Hide runes: </b>Hide See Blood<br>
				<b>Reveal hidden runes: </b>Blood See Hide<br>
				<b>Leave your body: </b>Hell travel self<br>
				<b>Ghost Manifest: </b>Blood See Travel<br>
				<b>Imbue a talisman: </b>Hell Technology Join<br>
				<b>Sacrifice: </b>Hell Blood Join<br>
				<b>Create a wall: </b>Destroy Travel Self<br>
				<b>Summon cultist: </b>Join Other Self<br>
				<b>Free a cultist: </b>Travel technology other<br>
				<b>Deafen: </b>Hide other see<br>
				<b>Blind: </b>Destroy See Other<br>
				<b>Blood Boil: </b>Destroy See Blood<br>
				<b>Communicate: </b>Self other technology<br>
				</p>
				<h2>Rune Descriptions</h2>
				<h3>Teleport self</h3>
				Teleport rune is a special rune, as it only needs two words, with the third word being destination. Basically, when you have two runes with the same destination, invoking one will teleport you to the other one. If there are more than 2 runes, you will be teleported to a random one. Runes with different third words will create separate networks. You can imbue this rune into a talisman, giving you a great escape mechanism.<br>
				<h3>Teleport other</h3>
				Teleport other allows for teleportation for any movable object to another rune with the same third word. You need 3 cultists chanting the invocation for this rune to work.<br>
				<h3>Summon new tome</h3>
				Invoking this rune summons a new arcane tome.
				<h3>Convert a person</h3>
				This rune opens target's mind to the realm of Nar-Sie, which usually results in this person joining the cult. However, some people (mostly the ones who posess high authority) have strong enough will to stay true to their old ideals. <br>
				<h3>Tear Reality</h3>
				The ultimate rune. It tears reality, consuming everything around it and moving Nar-Sie's reawakening a little closer. Summoning it is the final goal of any cult.<br>
				<h3>Disable Technology</h3>
				Invoking this rune creates a strong electromagnetic pulse in a small radius, making it basically analogic to an EMP grenade. You can imbue this rune into a talisman, making it a decent defensive item.<br>
				<h3>Drain Blood</h3>
				This rune instantly heals you of some brute damage at the expense of a person placed on top of the rune. Whenever you invoke a drain rune, ALL drain runes on the station are activated, draining blood from anyone located on top of those runes. This includes yourself, though the blood you drain from yourself just comes back to you. This might help you identify this rune when studying words. One drain gives up to 25HP per each victim, but you can repeat it if you need more. Draining only works on living people, so you might need to recharge your "Battery" once its empty. Drinking too much blood at once might cause blood hunger.<br>
				<h3>Raise Dead</h3>
				This rune allows for the resurrection of any dead person. You will need a dead human body and a living human sacrifice. Make 2 raise dead runes. Put a living non-braindead human on top of one, and a dead body on the other one. When you invoke the rune, the life force of the living human will be transferred into the dead body, allowing a ghost standing on top of the dead body to enter it, instantly and fully healing it. Use other runes to ensure there is a ghost ready to be resurrected.<br>
				<h3>Hide runes</h3>
				This rune makes all nearby runes completely invisible. They are still there and will work if activated somehow, but you cannot invoke them directly if you do not see them.<br>
				<h3>Reveal runes</h3>
				This rune is made to reverse the process of hiding a rune. It reveals all hidden runes in a rather large area around it.
				<h3>Leave your body</h3>
				This rune gently rips your soul out of your body, leaving it intact. You can observe the surroundings as a ghost as well as communicate with other ghosts. Your body takes damage while you are there, so ensure your journey is not too long, or you might never come back.<br>
				<h3>Manifest a ghost</h3>
				Unlike the Raise Dead rune, this rune does not require any special preparations or vessels. Instead of using full lifeforce of a sacrifice, it will drain YOUR lifeforce. Stand on the rune and invoke it. If theres a ghost standing over the rune, it will materialise, and will live as long as you dont move off the rune or die. You can put a paper with a name on the rune to make the new body look like that person.<br>
				<h3>Imbue a talisman</h3>
				This rune allows you to imbue the magic of some runes into paper talismans. Create an imbue rune, then an appropriate rune beside it. Put an empty piece of paper on the imbue rune and invoke it. You will now have a one-use talisman with the power of the target rune. Using a talisman drains some health, so be careful with it. You can imbue a talisman with power of the following runes: summon tome, reveal, conceal, teleport, tisable technology, communicate, deafen, blind and stun.<br>
				<h3>Sacrifice</h3>
				Sacrifice rune allows you to sacrifice a living thing or a body to the Geometer of Blood. Monkeys and dead humans are the most basic sacrifices, they might or might not be enough to gain His favor. A living human is what a real sacrifice should be, however, you will need 3 people chanting the invocation to sacrifice a living person.
				<h3>Create a wall</h3>
				Invoking this rune solidifies the air above it, creating an an invisible wall. To remove the wall, simply invoke the rune again.
				<h3>Summon cultist</h3>
				This rune allows you to summon a fellow cultist to your location. The target cultist must be unhandcuffed ant not buckled to anything. You also need to have 3 people chanting at the rune to succesfully invoke it. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Free a cultist</h3>
				This rune unhandcuffs and unbuckles any cultist of your choice, no matter where he is. You need to have 3 people invoking the rune for it to work. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Deafen</h3>
				This rune temporarily deafens all non-cultists around you.<br>
				<h3>Blind</h3>
				This rune temporarily blinds all non-cultists around you. Very robust. Use together with the deafen rune to leave your enemies completely helpless.<br>
				<h3>Blood boil</h3>
				This rune boils the blood all non-cultists in visible range. The damage is enough to instantly critically hurt any person. You need 3 cultists invoking the rune for it to work. This rune is unreliable and may cause unpredicted effects when invoked. It also drains significant amount of your health when succesfully invoked.<br>
				<h3>Communicate</h3>
				Invoking this rune allows you to relay a message to all cultists on the station and nearby space objects.
				</body>
				</html>
				"}


	Topic(href,href_list[])
		if (src.loc == usr)
			var/number = text2num(href_list["number"])
			if (usr.stat|| usr.restrained())
				return
			switch(href_list["action"])
				if("clear")
					words[words[number]] = words[number]
				if("change")
					words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in engwords
					for (var/w in words)
						if ((words[w] == words[words[number]]) && (w != words[number]))
							words[w] = w
			notedat = {"
						<br><b>Word translation notes</b> <br>
						[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
						[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
						[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
						[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
						[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
						[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
						[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
						[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
						[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
						[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
						"}
			usr << browse("[notedat]", "window=notes")
		else
			usr << browse(null, "window=notes")
			return


	attack(mob/living/M as mob, mob/living/user as mob)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")

		if(istype(M,/mob/dead))
			M.invisibility = 0
			user.visible_message( \
				"\red [user] drags the ghost to our plan of reality!", \
				"\red You drag the ghost to our plan of reality!" \
			)
			return
		if(!istype(M))
			return
		if(!iscultist(user))
			return ..()
		if(iscultist(M))
			return
		M.take_organ_damage(0,rand(5,20)) //really lucky - 5 hits for a crit
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] beats [] with the arcane tome!</B>", user, M), 1)
		M << "\red You feel searing heat inside!"



	attack_self(mob/living/user as mob)
		usr = user
		if(!wordtravel)
			runerandom()
		if(iscultist(user))
			var/C = 0
			for(var/obj/rune/N in world)
				C++
			if (!istype(user.loc,/turf))
				user << "\red You do not have enough space to write a proper rune."
				return
			if (C>=26+runedec+ticker.mode.cult.len) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
				switch(alert("The cloth of reality can't take that much of a strain. By creating another rune, you risk locally tearing reality apart, which would prove fatal to you. Do you still wish to scribe the rune?",,"Yes","No"))
					if("Yes")
						if(prob(C*5-105-(runedec-ticker.mode.cult.len)*5)) //including the useless rune at the secret room, shouldn't count against the limit - Urist
							usr.emote("scream")
							user << "\red A tear momentarily appears in reality. Before it closes, you catch a glimpse of that which lies beyond. That proves to be too much for your mind."
							usr.gib(1)
							return
					if("No")
						return
			else
				switch(alert("You open the tome",,"Read it","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
					if("Cancel")
						return
					if("Read it")
						user << browse("[tomedat]", "window=Arcane Tome")
						return
					if("Notes")
						notedat = {"
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}
//						call(/obj/item/weapon/tome/proc/edit_notes)()
						user << browse("[notedat]", "window=notes")
						return
			var/w1
			var/w2
			var/w3
			var/list/english = list()
			for (var/w in words)
				english+=words[w]
			if(usr)
				w1 = input("Write your first rune:", "Rune Scribing") in english
				for (var/w in words)
					if (words[w] == w1)
						w1 = w
			if(usr)
				w2 = input("Write your second rune:", "Rune Scribing") in english
				for (var/w in words)
					if (words[w] == w2)
						w2 = w
			if(usr)
				w3 = input("Write your third rune:", "Rune Scribing") in english
				for (var/w in words)
					if (words[w] == w3)
						w3 = w
			for (var/mob/V in viewers(src))
				V.show_message("\red [user] slices open a finger and begins to chant and paint symbols on the floor.", 3, "\red You hear chanting.", 2)
			user << "\red You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			user.take_overall_damage(1)
			if(do_after(user, 50))
				var/mob/living/carbon/human/H = user
				var/obj/rune/R = new /obj/rune(user.loc)
				user << "\red You finish drawing the arcane markings of the Geometer."
				R.word1 = w1
				R.word2 = w2
				R.word3 = w3
				R.check_words()
				R.blood_DNA = H.dna.unique_enzymes
				R.blood_type = H.b_type
			return
		else
			user << "The book seems full of illegible scribbles. Is this a joke?"
			return

	attackby(obj/T as obj, mob/living/user as mob)
		if(istype(T, /obj/item/weapon/tome))
			switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
				if("cancel")
					return
			for(var/w in words)
				words[w] = T:words[w]
			user << "You copy the translation notes from your tome."


	examine()
		set src in usr
		if(!iscultist(usr))
			usr << "An old, dusty tome with frayed edges and a sinister looking cover."
		else
			usr << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though."

/obj/item/weapon/tome/imbued //admin tome, spawns working runes without waiting
	w_class = 2.0
	var/cultistsonly = 1
	attack_self(mob/user as mob)
		if(src.cultistsonly && !iscultist(usr))
			return
		if(!wordtravel)
			runerandom()
		if(user)
			var/r
			if (!istype(user.loc,/turf))
				user << "\red You do not have enough space to write a proper rune."
			var/list/runes = list("teleport", "gate", "tome", "convert", "tear in reality", "emp", "drain", "truesight", "raise", "obscure", "reveal", "astral journey", "manifest", "imbue seal", "sacrifice", "wall", "freedom", "cultsummon", "deafen", "blind", "bloodboil", "communicate", "explode", "hold")
			r = input("Choose a rune to scribe", "Rune Scribing") in runes //not cancellable.
			var/obj/rune/R = new /obj/rune
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				R.blood_DNA = H.dna.unique_enzymes
				R.blood_type = H.b_type
			switch(r)
				if("teleport")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in cultwords
					R.word1=wordtravel
					R.word2=wordself
					R.word3=beacon
					R.runetype = "teleport"
					R.loc = user.loc
					R.check_icon()
				if("gate")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in cultwords
					R.word1=wordtravel
					R.word2=wordother
					R.word3=beacon
					R.runetype = "gate"
					R.loc = user.loc
					R.check_icon()
				if("tome")
					R.word1=wordsee
					R.word2=wordblood
					R.word3=wordhell
					R.runetype = "tome"
					R.loc = user.loc
					R.check_icon()
				if("convert")
					R.word1=wordjoin
					R.word2=wordblood
					R.word3=wordself
					R.runetype = "convert"
					R.loc = user.loc
					R.check_icon()
				if("tear in reality")
					R.word1=wordhell
					R.word2=wordjoin
					R.word3=wordself
					R.runetype = "terror"
					R.loc = user.loc
					R.check_icon()
				if("emp")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordtech
					R.runetype = "emp"
					R.loc = user.loc
					R.check_icon()
				if("drain")
					R.word1=wordtravel
					R.word2=wordblood
					R.word3=wordself
					R.runetype = "drain"
					R.loc = user.loc
					R.check_icon()
				if("truesight")
					R.word1=wordsee
					R.word2=wordhell
					R.word3=wordjoin
					R.runetype = "truesight"
					R.loc = user.loc
					R.check_icon()
				if("raise")
					R.word1=wordblood
					R.word2=wordjoin
					R.word3=wordhell
					R.runetype = "raise"
					R.loc = user.loc
					R.check_icon()
				if("obscure")
					R.word1=wordhide
					R.word2=wordsee
					R.word3=wordblood
					R.runetype = "obscure"
					R.loc = user.loc
					R.check_icon()
				if("astral journey")
					R.word1=wordhell
					R.word2=wordtravel
					R.word3=wordself
					R.runetype = "scry"
					R.loc = user.loc
					R.check_icon()
				if("manifest")
					R.word1=wordblood
					R.word2=wordsee
					R.word3=wordtravel
					R.runetype = "manifest"
					R.loc = user.loc
					R.check_icon()
				if("imbue seal")
					R.word1=wordhell
					R.word2=wordtech
					R.word3=wordjoin
					R.runetype = "seal"
					R.loc = user.loc
					R.check_icon()
				if("sacrifice")
					R.word1=wordhell
					R.word2=wordblood
					R.word3=wordjoin
					R.runetype = "sacrifice"
					R.loc = user.loc
					R.check_icon()
				if("reveal")
					R.word1=wordblood
					R.word2=wordsee
					R.word3=wordhide
					R.runetype = "reveal"
					R.loc = user.loc
					R.check_icon()
				if("wall")
					R.word1=worddestr
					R.word2=wordtravel
					R.word3=wordself
					R.runetype = "wall"
					R.loc = user.loc
					R.check_icon()
				if("freedom")
					R.word1=wordtravel
					R.word2=wordtech
					R.word3=wordother
					R.runetype = "freedom"
					R.loc = user.loc
					R.check_icon()
				if("cultsummon")
					R.word1=wordjoin
					R.word2=wordother
					R.word3=wordself
					R.runetype = "summon"
					R.loc = user.loc
					R.check_icon()
				if("deafen")
					R.word1=wordhide
					R.word2=wordother
					R.word3=wordsee
					R.runetype = "deafen"
					R.loc = user.loc
					R.check_icon()
				if("blind")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordother
					R.runetype = "blind"
					R.loc = user.loc
					R.check_icon()
				if("bloodboil")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordblood
					R.runetype = "bloodboil"
					R.loc = user.loc
					R.check_icon()
				if("communicate")
					R.word1=wordself
					R.word2=wordother
					R.word3=wordtech
					R.runetype = "contact"
					R.loc = user.loc
					R.check_icon()
				if("explode")
					R.word1=wordblood
					R.word2=worddestr
					R.word3=wordhell
					R.runetype = "explode"
					R.loc = user.loc
					R.check_icon()
				if("hold")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in cultwords
					R.word1=wordtravel
					R.word2=worddestr
					R.word3=beacon
					R.runetype = "hold"
					R.loc = user.loc
					R.check_icon()

/*/obj/item/weapon/paperscrap
	name = "scrap of paper"
	icon_state = "scrap"
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	flags = FPRINT | TABLEPASS

	var
		data

	attack_self(mob/user as mob)
		view_scrap(user)

	examine()
		set src in usr
		view_scrap(usr)

	proc/view_scrap(var/viewer)
		viewer << browse(data)*/

/obj/item/weapon/paper/talisman
	icon_state = "papertalisman"
	var/imbue = null
	var/uses = 0

	attack_self(mob/living/user as mob)
		if(iscultist(user))
			switch(imbue)
				if("supply")
					supply()
				if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					call(/obj/rune/proc/teleport)(imbue)
				if("reveal")
					call(/obj/rune/proc/reveal)(src)
				if("emp")
					call(/obj/rune/proc/emp)(user,3)
				if("explode")
					user << "There's Explosive Runes writing on talisman. It reads: <i>[src.info]</i>"
					return
				else
					if(imbue)
						var/temp = text2path("/obj/rune/proc/[imbue]")
						call(temp)()
			user.take_organ_damage(3, 0)
			if(src && src.imbue!="supply")
				del(src)
			return
		else
			if(imbue == "explode")
				user << "You see text written on paper in strange font. It reads: <i>[src.info]</i>"
				sleep(30)
				explosion (user.loc, -1, 0, 3, 5)
				if(src)
					del(src)
			else
				user << "You see strange symbols on the paper. Are they supposed to mean something?"
			return

/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 3
