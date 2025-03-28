#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"

///////////////////////////////////////////////
////////////////AMMO SECTION///////////////////
///////////////////////////////////////////////

/obj/item/projectile
	name = "projectile"
	icon = 'projectiles.dmi'
	icon_state = "bullet"
	density = 1
	throwforce = 0.1 //an attempt to make it possible to shoot your way through space
	unacidable = 1 //Just to be sure.
	anchored = 1 // I'm not sure if it is a good idea. Bullets sucked to space and curve trajectories near singularity could be awesome. --rastaf0
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT // ONBELT??? // Catch those when server lags too hard and wear them on belt, lol -- Nikie
	var
		def_zone = ""
		//damage_type = PROJECTILE_BULLET
		mob/firer = null
		silenced = 0
		yo = null
		xo = null
		current = null
		turf/original = null

		damage = 50		// damage dealt by projectile. This is used for machinery, livestock, anything not under /mob heirarchy
		flag = "bullet" // identifier flag (bullet, laser, bio, rad, taser). This is to identify what kind of armor protects against the shot

		nodamage = 0 // determines if the projectile will skip any damage inflictions
		list/mobdamage = list(BRUTE = 50, BURN = 0, TOX = 0, OXY = 0, CLONE = 0) // determines what kind of damage it does to mobs
		list/effects = list("stun" = 0, "weak" = 0, "paralysis" = 0, "stutter" = 0, "drowsyness" = 0, "radiation" = 0, "eyeblur" = 0, "emp" = 0) // long list of effects a projectile can inflict on something. !!MUY FLEXIBLE!!~
		list/effectprob = list("stun" = 100, "weak" = 100, "paralysis" = 100, "stutter" = 100, "drowsyness" = 100, "radiation" = 100, "eyeblur" = 100, "emp" = 100) // Probability for an effect to execute
		list/effectmod = list("stun" = SET, "weak" = SET, "paralysis" = SET, "stutter" = SET, "drowsyness" = SET, "radiation" = SET, "eyeblur" = SET, "emp" = SET) // determines how the effect modifiers will effect a mob's variable

		bumped = 0

	weakbullet
		damage = 15
		mobdamage = list(BRUTE = 15, BURN = 0, TOX = 0, OXY = 0, CLONE = 0)

	beam
		name = "laser"
		icon_state = "laser"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 20
		mobdamage = list(BRUTE = 0, BURN = 20, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["eyeblur"] = 5
			effectprob["eyeblur"] = 50

		pulse
			name = "pulse"
			icon_state = "u_laser"
			damage = 50
			mobdamage = list(BRUTE = 10, BURN = 40, TOX = 0, OXY = 0, CLONE = 0)

	fireball
		name = "shock"
		icon_state = "fireball"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 25
		mobdamage = list(BRUTE = 0, BURN = 25, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["stun"] = 10
			effects["weak"] = 10
			effects["stutter"] = 10
			effectprob["weak"] = 25

	declone
		name = "declone"
		icon_state = "declone"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 0
		mobdamage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0, CLONE = 70)
		flag = "bio"

	dart
		name = "dart"
		icon_state = "toxin"
		flag = "bio"
		damage = 0
		mobdamage = list(BRUTE = 0, BURN = 0, TOX = 10, OXY = 0, CLONE = 0)
		New()
			..()
			effects["weak"] = 5
			effectmod["weak"] = ADD

	electrode
		name = "electrode"
		icon_state = "spark"
		flag = "taser"
		damage = 0
		nodamage = 1
		New()
			..()
			effects["stun"] = 10
			effects["weak"] = 10
			effects["stutter"] = 10
			effectprob["weak"] = 25

	bolt
		name = "bolt"
		icon_state = "cbbolt"
		flag = "rad"
		damage = 0
		nodamage = 1
		New()
			..()
			effects["radiation"] = 100
			effects["drowsyness"] = 5
			effectmod["radiation"] = ADD
			effectmod["drowsyness"] = ADD

	freeze
		name = "freeze beam"
		icon_state = "ice_2"
		var/temperature = 0

		proc/Freeze(atom/A as mob|obj|turf|area)
			if(istype(A, /mob))
				var/mob/M = A
				if(M.bodytemperature > temperature)
					M.bodytemperature = temperature

	plasma
		name = "plasma blast"
		icon_state = "plasma_2"
		var/temperature = 800

		proc/Heat(atom/A as mob|obj|turf|area)
			if(istype(A, /mob/living/carbon))
				var/mob/M = A
				if(M.bodytemperature < temperature)
					M.bodytemperature = temperature

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return // cannot shoot yourself

		if(bumped) return

		bumped = 1
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return // nope.avi

			if(!silenced)
				/*
				for(var/mob/O in viewers(M))
					O.show_message("\red [A.name] has been shot by [firer.name]!", 1) */

				visible_message("\red [A.name] has been shot by [firer.name]!", "\blue You hear a [istype(src, /obj/item/projectile/beam) ? "gunshot" : "laser blast"]!")
			else
				M << "\red You've been shot!"
			if(istype(firer, /mob))
				M.attack_log += text("[] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, firer, firer.ckey, M, M.ckey, src)
				firer.attack_log += text("[] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, firer, firer.ckey, M, M.ckey, src)
			else
				M.attack_log += text("[] <b>UNKOWN SUBJECT (No longer exists)</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, M, M.ckey, src)
		spawn(0)
			if(A)

				if(istype(src, /obj/item/projectile/freeze))
					var/obj/item/projectile/freeze/F = src
					F.Freeze(A)
				else if(istype(src, /obj/item/projectile/plasma))
					var/obj/item/projectile/plasma/P = src
					P.Heat(A)
				else

					A.bullet_act(src, def_zone)
					if(istype(A,/turf) && !istype(src, /obj/item/projectile/beam))
						for(var/obj/O in A)
							O.bullet_act(src, def_zone)
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1

	process()
		spawn while(src)

			if ((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if ((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src)
				return
			step_towards(src, current)

			sleep( 1 )

			if(!bumped)
				if(loc == original)
					for(var/mob/living/M in original)
						Bump(M)
						sleep( 1 )
		return

/obj/item/bullet // these are actual BULLETS
	name = "bullet"
	desc = "An unknown bullet."
	icon = 'ammo.dmi'
	icon_state = "bullet-357"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 1
	w_class = 1.0
	layer = 2
	var
		caliber // what kind of guns using it
		caliber_2 // second caliber, e.g. lethal detective's ammo
		obj/item/projectile/BB // bullet's projectile that kills, you know
		//obj/item/ammo_casing/AC // thing that falls out a gun

	c357 // bullet calibers
		name = "bullet (.357)"
		desc = "A .357 bullet"
		caliber = "357"

		casing // and their casings
			name = "bullet casing (.375)"
			desc = "A .357 bullet casing."
			icon_state = "casing-357"
			m_amt = 50

		New()
			BB = new /obj/item/projectile(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	c38 // cal 38, default detective's bullets, those zephyr kind
		name = "bullet (.38)"
		desc = "A .38 bullet."
		caliber = "38"
		icon_state = "bullet-38"

		casing
			name = "bullet casing (.38)"
			desc = "A .38 bullet casing."
			icon_state = "casing-38"
			m_amt = 50

		special // normal kind of bullets
			name = "bullet (.38 special)"
			desc = "A .38 special bullet"
			caliber = null
			caliber_2 = "38s"
			icon_state = "bullet-38s"

			casing
				name = "bullet casing (.38 special)"
				desc = "A .38 special bullet casing."
				icon_state = "casing-38s"
				m_amt = 50

			New()
				BB = new /obj/item/projectile(src)
				pixel_x = rand(-10.0, 10)
				pixel_y = rand(-10.0, 10)
				dir = pick(cardinal)

		New()
			BB = new /obj/item/projectile/weakbullet(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	c9mm
		name = "bullet (9mm)"
		desc = "A 9mm bullet."
		caliber = "9mm"
		icon_state = "bullet-9mm"

		casing
			name = "bullet casing (9mm)"
			desc = "A 9mm bullet casing."
			icon_state = "casing-9mm"
			m_amt = 50

		New()
			BB = new /obj/item/projectile/weakbullet(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	c45
		name = "bullet (.45)"
		desc = "A .45 bullet."
		caliber = ".45"
		icon_state = "bullet-45"

		casing
			name = "bullet casing (.45)"
			desc = "A .45 bullet casing."
			icon_state = "casing-45"
			m_amt = 50

		New()
			BB = new /obj/item/projectile(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)


	shotgun
		name = "12 gauge shell"
		desc = "A 12gauge shell."
		icon_state = "shell-gauge"
		caliber = "shotgun"
		m_amt = 25000

		gauge

			casing
				name = "empty shell (12gauge)"
				desc = "An empty 12 gauge shell."
				icon = 'ammo.dmi'
				icon_state = "casing-shell-gauge"
				m_amt = 50

		New()
			BB = new /obj/item/projectile
			src.pixel_x = rand(-10.0, 10)
			src.pixel_y = rand(-10.0, 10)

		blank
			name = "blank shell"
			desc = "A blank shell."
			icon_state = "shell-blank"
			m_amt = 500

			casing
				name = "empty shell (blank)"
				desc = "An empty blank shell."
				icon_state = "casing-shell-blank"
				m_amt = 50

			New()
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		beanbag
			name = "beanbag shell"
			desc = "A weak beanbag shell."
			icon_state = "shell-beanbag"
			m_amt = 10000

			casing
				name = "empty shell (beanbag)"
				desc = "An empty beanbag shell."
				icon_state = "casing-shell-beanbag"
				m_amt = 50

			New()
				BB = new /obj/item/projectile/weakbullet
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		dart
			name = "shotgun dart"
			desc = "A dart shell"
			icon_state = "shell-dart"
			m_amt = 50000

			casing
				name = "empty shell (dart)"
				desc = "An empty dart shell."
				icon_state = "casing-shell-dart"
				m_amt = 50

			New()
				BB = new /obj/item/projectile/dart
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

/obj/item/ammo_magazine
	name = "ammo box (.357)"
	desc = "A box of .357 ammo"
	icon_state = "357"
	icon = 'ammo.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	item_state = "syringe_kit"
	m_amt = 50000
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	var
		list/stored_ammo = list()

	c357
		New()
			for(var/i = 1, i <= 7, i++)
				stored_ammo += new /obj/item/bullet/c357(src)
			update_icon()

	New()
		for(var/i = 1, i <= 7, i++)
			stored_ammo += new /obj/item/bullet/c357(src)
		update_icon()

	update_icon()
		icon_state = text("[initial(icon_state)]-[]", stored_ammo.len)
		desc = text("There are [] shell\s left!", stored_ammo.len)

	c38
		name = "speed loader (.38)"
		icon_state = "38"
		New()
			for(var/i = 1, i <= 7, i++)
				stored_ammo += new /obj/item/bullet/c38(src)
			update_icon()

		special
			name = "speed loader (.38 special)"
			icon_state = "T38"
			New()
				for(var/i = 1, i <= 7, i++)
					stored_ammo += new /obj/item/bullet/c38/special(src)
				update_icon()

	c9mm
		name = "Ammunition Box (9mm)"
		icon_state = "9mm"
		origin_tech = "combat=3;materials=2"
		New()
			for(var/i = 1, i <= 20, i++) // only the submachine gun and mini-uzi uses them, and it 18 and 20, so we dont need 30 of those in box
				stored_ammo += new /obj/item/bullet/c9mm(src)
			update_icon()

		update_icon()
			desc = text("There are [] round\s left!", stored_ammo.len)

	c45
		name = "Ammunition Box (.45)"
		icon_state = "9mm"
		origin_tech = "combat=3;materials=2"
		New()
			for(var/i = 1, i <= 30, i++)
				stored_ammo += new /obj/item/bullet/c45(src)
			update_icon()

		update_icon()
			desc = text("There are [] round\s left!", stored_ammo.len)

	shotgun
		name = "ammo box (12gauge)"
		desc = "A box of 12 gauge shell"
		icon_state = "shotgun"
		m_amt = 25000

		New()
			for(var/i = 1, i <= 12, i++)
				stored_ammo += new /obj/item/bullet/shotgun/gauge(src)
			update_icon()

/*
GUNS:
	GUN -> SYNDICATE - DETECTIVE - COLT 1911 / MATEBA / SHOTGUN - COMBAT / AUTOMATIC - MINI-UZI / SILENCED
	ENERGY -> LASER - CAPTAIN / PULZE RIFLE - DESTROYER - M1911 / NUCLEAR / TASER / CROSSBOW
*/

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though." // BADMINS SPAWN SHIT
	icon = 'gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	m_amt = 2000
	w_class = 3.0
	throw_speed = 4
	throwforce = 5
	throw_range = 10
	force = 10

	origin_tech = "combat=1"
	var
		fire_sound
		fire_sound_1
		fire_sound_2 // you can customise those now and have like 3 different sounds! Like in CS:S!
		fire_sound_3
		reload_sound
		loudness = 50 // standard default loundness is too high for silenced pistol and crossbow, so its a var
		projectiles_per_shot = 1 // shooting 1 bullet per "click"
		obj/item/projectile/in_chamber
		caliber = "" // if you dont set the caliber, it will use obj/item/bullet, better dont do this
		caliber_2 // second caliber, like c38 and c38/special
		silenced = 0
		badmin = 0

	projectile
		desc = "A classic revolver. Uses 357 ammo"
		name = "revolver"
		icon_state = "revolver"
		caliber = "357"
		origin_tech = "combat=2;materials=2;syndicate=6"
		w_class = 3.0
		throw_speed = 2
		throw_range = 10
		m_amt = 1000
		force = 24
		var
			list/loaded = list()
			max_shells = 7
			load_method = 0 //0 = Single shells or quick loader, 1 = magazine
			
			// Shotgun variables
			pumped = 1
			maxpump = 1

		syndicate // we spawn that thing, because otherwise all child objects start to use this sounds, NOT COOL -- Nikie
			fire_sound_1 = 'revolver_syndicate_1.ogg'
			fire_sound_2 = 'revolver_syndicate_2.ogg'
			fire_sound_3 = 'revolver_syndicate_3.ogg'
			reload_sound = 'revolver_syndicate_reload.ogg'
			caliber = "357"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/c357(src)
				update_icon()

		load_into_chamber()
			if(!loaded.len)
				return 0
			if(pumped >= maxpump && istype(src, /obj/item/weapon/gun/projectile/shotgun))
				return 1
			var/obj/item/bullet/ABullet = loaded[1] // load next bullet
			var/bullet_casing = text2path("[ABullet.type]/casing") // its gonna be like '/obj/item/bullet/c38/casing/'
			loaded -= ABullet // remove the damn bullet from loaded list.
			//ABullet.loc = get_turf(src) // Eject casing onto ground.
			var/obj/BC = new bullet_casing(get_turf(src)) // create a casing on the ground
			if(ABullet.fingerprints)
				BC.fingerprints = ABullet.fingerprints // bullet is a cartridge, actuacly, so when you touch the cartridge, you touch the case and the bullet, so we transfer the fingerprints to ejected case. As far as I understand -- Nikie
			if(ABullet.BB)
				in_chamber = ABullet.BB // Load projectile into chamber.
				ABullet.BB.loc = src // Set projectile loc to gun.
				del(ABullet)
				return 1
			else
				del(ABullet)
				return 0

		New()
			for(var/i = 1, i <= max_shells, i++)
				loaded += new /obj/item/bullet/c357(src)
			update_icon()

		attackby(var/obj/item/A as obj, mob/user as mob)
			var/num_loaded = 0
			var/casing = text2path("[A]/casing")
			if(istype(A, /obj/item/ammo_magazine)) // BB - projectile (bullet ball?)
				var/obj/item/ammo_magazine/AM = A // AM - ammo magazine
				for(var/obj/item/bullet/AB in AM.stored_ammo) // AB - ammo bullet, AC - ammo casing
					if(loaded.len >= max_shells)
						break
					if((AB.caliber == caliber || AB.caliber_2 == caliber_2) && loaded.len < max_shells)
						AB.loc = src
						AM.stored_ammo -= AB
						loaded += AB
						num_loaded++
			else if(istype(A, /obj/item/bullet) && !istype(A, casing) && !load_method) // bullet and not casing, without a casing check we would be able to put casings back inside -- Nikie
				var/obj/item/bullet/AB = A
				if(AB.caliber == caliber || AB.caliber_2 == caliber_2)
					if(loaded.len < max_shells)
						user.drop_item()
						AB.loc = src
						loaded += AB
						num_loaded++
			if(num_loaded)
				user << text("\blue You load [] shell\s into the gun!", num_loaded)
				for(var/mob/O in hearers(user, null))
					if(reload_sound)
						playsound(user, reload_sound, 50, 1) // reload sound, if you have it
			A.update_icon()
			return

		update_icon()
			desc = initial(desc) + text(" Has [] rounds remaining.", loaded.len)

		detective
			desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38 ammo."
			name = ".38 revolver"
			icon_state = "detective"
			fire_sound_1 = 'revolver_detective_1.ogg'
			fire_sound_2 = 'revolver_detective_2.ogg'
			fire_sound_3 = 'revolver_detective_3.ogg'
			reload_sound = 'revolver_detective_reload.ogg'
			force = 14.0
			caliber = "38" // zyphyr 14 damage ones
			caliber_2 = "38s" // lethal 51 damage ones
			origin_tech = "combat=2;materials=2"

			colt1911
				name = "colt 1911"
				desc = "Weapon of choice for a good detective. Uses .38 ammo."
				icon_state = "detective1911"
				fire_sound_1 = 'gun_colt_fire.ogg'
				fire_sound_2 = null
				fire_sound_3 = null
				reload_sound = 'gun_colt_reload.ogg'

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/c38(src)
				update_icon()

			special_check(var/mob/living/carbon/human/M)
				if(istype(M))
					if(istype(M.w_uniform, /obj/item/clothing/under/det) && istype(M.head, /obj/item/clothing/head/det_hat) && istype(M.wear_suit, /obj/item/clothing/suit/det_suit))
						return 1
					M << "\red You just don't feel cool enough to use this gun looking like that."
				return 0

			verb
				rename_gun()
					set name = "Name Gun"
					set desc = "Click to rename your gun. If you're the detective."
					set category = "Object" // no need for Commands to appear just for this

					var/mob/U = usr
					if(ishuman(U) && U.mind && U.mind.assigned_role == "Detective")
						var/input = input("How do you want to name the gun?",,"")
						input = sanitize(input)
						if(input)
							if(in_range(U,src) && (!isnull(src)) && !U.stat)
								name = input
								U << "You name the gun a &quot;[input]&quot;. Say hello to your little friend."
							else
								U << "\red Can't let you do that, detective!"
					else
						U << "\red You don't feel cool enough to name this gun, chump."

		mateba
			name = "mateba"
			desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
			icon_state = "mateba"
			fire_sound_1 = 'revolver_centcomm_1.ogg'
			reload_sound = 'revolver_syndicate_reload.ogg'
			origin_tech = "combat=2;materials=2"
			caliber = "357" // childed to gun, so we need to define the caliber

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/c357(src)
				update_icon()

		shotgun
			name = "shotgun"
			desc = "Useful for sweeping alleys."
			icon_state = "shotgun"
			fire_sound_1 = 'gun_shotgun_1.ogg'
			fire_sound_2 = 'gun_shotgun_2.ogg'
			reload_sound = 'gun_shotgun_reload.ogg'
			max_shells = 2
			w_class = 4.0
			force = 7.0
			flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
			caliber = "shotgun"
			origin_tech = "combat=2;materials=2"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/shotgun/beanbag(src)
				update_icon()
				pumped = maxpump

			combat
				name = "combat shotgun"
				icon_state = "cshotgun"
				w_class = 4.0
				force = 12.0
				flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
				max_shells = 8
				origin_tech = "combat=3"
				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/bullet/shotgun/gauge(src)
					update_icon()
					
			proc/pump(mob/M)
				for(var/mob/O in hearers(user, null))
					playsound(M, 'gun_shotgun_pump.ogg', 60, 1) // tg one - 'shotgunpump.ogg'
				pumped = 0

		automatic
			name = "Submachine Gun"
			desc = "A lightweight, fast firing gun. Uses 9mm rounds."
			icon_state = "saber"
			fire_sound_1 = 'automatic_submachine_1.ogg'
			fire_sound_2 = 'automatic_submachine_2.ogg'
			reload_sound = 'automatic_submachine_reload.ogg'
			projectiles_per_shot = 3 // 3 round burst
			w_class = 3.0
			force = 7
			max_shells = 18
			caliber = "9mm"
			origin_tech = "combat=4;materials=2"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/c9mm(src)
				update_icon()

			mini_uzi
				name = "Mini-Uzi"
				desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses .45 rounds."
				icon_state = "mini-uzi"
				fire_sound_1 = 'automatic_uzi_1.ogg'
				fire_sound_2 = null
				reload_sound = 'automatic_uzi_reload.ogg'
				w_class = 3.0
				force = 16
				max_shells = 20
				caliber = "9mm" // 3 round .45 cal burst of 51 damage projectiles? No way, sire.
				origin_tech = "combat=5;materials=2;syndicate=8"

				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/bullet/c9mm(src)
					update_icon()

		silenced
			name = "Silenced Pistol"
			desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
			icon_state = "silenced_pistol"
			fire_sound_1 = 'gun_silenced.ogg'
			reload_sound = 'gun_colt_reload.ogg'
			w_class = 3.0
			force = 14.0
			max_shells = 12
			caliber = ".45"
			silenced = 1
			loudness = 25 // silence!
			origin_tech = "combat=2;materials=2;syndicate=8"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/bullet/c45(src)
				update_icon()

	energy
		icon_state = "energy"
		name = "energy gun"
		desc = "A basic energy-based gun with two settings: Stun and kill."
		fire_sound_1 = 'Taser.ogg' // primary mode is stun
		var
			var/obj/item/weapon/cell/power_supply
			mode = 0 //0 = stun, 1 = kill
			charge_cost = 100 //How much energy is needed to fire.

		New()
			power_supply = new(src)
			power_supply.give(power_supply.maxcharge)

		load_into_chamber()
			if(in_chamber)
				return 1
			if(!power_supply)
				return 0
			if(power_supply.charge < charge_cost)
				return 0
			switch (mode)
				if(0)
					in_chamber = new /obj/item/projectile/electrode(src)
				if(1)
					in_chamber = new /obj/item/projectile/beam(src)
			power_supply.use(charge_cost)
			return 1

		attack_self(mob/living/user as mob)
			switch(mode)
				if(0)
					mode = 1
					charge_cost = 100
					fire_sound_1 = 'gun_energy_1.ogg'
					fire_sound_2 = 'gun_energy_2.ogg'
					user << "\red [src.name] is now set to kill."
				if(1)
					mode = 0
					charge_cost = 100
					fire_sound_1 = 'Taser.ogg'
					fire_sound_2 = null
					user << "\red [src.name] is now set to stun."
			update_icon()
			return

		update_icon()
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			icon_state = text("[][]", initial(icon_state), ratio)

		laser
			name = "laser gun"
			icon_state = "laser"
			fire_sound_1 = 'gun_laser_1.ogg'
			fire_sound_2 = 'gun_laser_2.ogg'
			w_class = 3.0
			throw_speed = 2
			throw_range = 10
			force = 7.0
			m_amt = 2000
			origin_tech = "combat=3;magnets=2"
			mode = 1 //We don't want laser guns to be on a stun setting. --Superxpdude

			attack_self(mob/living/user as mob)
				return // We don't want laser guns to be able to change to a stun setting. --Superxpdude

			captain
				icon_state = "caplaser"
				desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
				force = 10
				origin_tech = null //forgotten technology of ancients lol
				fire_sound_1 = 'gun_laser_captain_1.ogg'
				fire_sound_2 = 'gun_laser_captain_2.ogg'

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/beam(src)
						return 1
					return 0

		pulse_rifle
			name = "pulse rifle"
			desc = "A heavy-duty, pulse-based energy weapon with multiple fire settings, preferred by front-line combat personnel."
			icon_state = "pulse"
			fire_sound_1 = 'gun_pulse_1.ogg'
			fire_sound_2 = 'gun_pulse_2.ogg'
			force = 15
			mode = 2
			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				switch (mode)
					if(0)
						in_chamber = new /obj/item/projectile/electrode(src)
					if(1)
						in_chamber = new /obj/item/projectile/beam(src)
					if(2)
						in_chamber = new /obj/item/projectile/beam/pulse(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				mode++
				switch(mode)
					if(1)
						user << "\red [src.name] is now set to kill."
						fire_sound_1 = 'gun_laser_1.ogg'
						fire_sound_2 = 'gun_laser_2.ogg'
						charge_cost = 100
					if(2)
						user << "\red [src.name] is now set to destroy."
						fire_sound_1 = 'gun_pulse_1.ogg'
						fire_sound_2 = 'gun_pulse_2.ogg'
						charge_cost = 200
					else
						mode = 0
						user << "\red [src.name] is now set to stun."
						fire_sound_1 = 'Taser.ogg'
						fire_sound_2 = null
						charge_cost = 50
			New()
				power_supply = new /obj/item/weapon/cell/super(src)
				power_supply.give(power_supply.maxcharge)
				update_icon()

			destroyer
				name = "pulse destroyer"
				desc = "A heavy-duty, pulse-based energy weapon. The mode is set to DESTROY. Always destroy."
				mode = 2
				New()
					power_supply = new /obj/item/weapon/cell/infinite(src)
					power_supply.give(power_supply.maxcharge)
					update_icon()
				attack_self(mob/living/user as mob)
					return
			M1911
				name = "m1911-P"
				desc = "It's not the size of the gun, it's the size of the hole it puts through people."
				icon_state = "m1911-p"
				New()
					power_supply = new /obj/item/weapon/cell/infinite(src)
					power_supply.give(power_supply.maxcharge)
					update_icon()

		nuclear
			name = "Advanced Energy Gun"
			desc = "An energy gun with an experimental miniaturized reactor."
			origin_tech = "combat=3;materials=5;powerstorage=3"
			var/lightfail = 0
			icon_state = "nucgun"
			fire_sound_1 = 'Taser.ogg' // stun is default
			fire_sound_2 = null

			New()
				..()
				charge()

			proc
				charge()
					if(power_supply.charge < power_supply.maxcharge)
						if(failcheck())
							power_supply.give(100)
					update_icon()
					if(!crit_fail)
						spawn(50) charge()

				failcheck()
					lightfail = 0
					if (prob(src.reliability)) return 1 //No failure
					if (prob(src.reliability))
						for (var/mob/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
							if (src in M.contents)
								M << "\red Your gun feels pleasantly warm for a moment."
							else
								M << "\red You feel a warm sensation."
							M.radiation += rand(1,40)
						lightfail = 1
					else
						for (var/mob/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
							if (src in M.contents)
								M << "\red Your gun's reactor overloads!"
							M << "\red You feel a wave of heat wash over you."
							M.radiation += 100
						crit_fail = 1 //break the gun so it stops recharging
						update_icon()

				update_charge()
					if (crit_fail)
						overlays += "nucgun-whee"
						return
					var/ratio = power_supply.charge / power_supply.maxcharge
					ratio = round(ratio, 0.25) * 100
					overlays += text("nucgun-[]", ratio)

				update_reactor()
					if(crit_fail)
						overlays += "nucgun-crit"
						return
					if(lightfail)
						overlays += "nucgun-medium"
					else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
						overlays += "nucgun-light"
					else
						overlays += "nucgun-clean"

				update_mode()
					if (mode == 2)
						overlays += "nucgun-stun"
					else if (mode == 1)
						overlays += "nucgun-kill"

			emp_act(severity)
				..()
				reliability -= round(15/severity)

			update_icon()
				overlays = null
				update_charge()
				update_reactor()
				update_mode()

		taser
			name = "taser gun"
			desc = "A small, low capacity gun used for non-lethal takedowns."
			icon_state = "taser"
			fire_sound_1 = 'Taser.ogg'
			fire_sound_2 = null // thats because its a child of energy gun which uses its own sounds, bwah
			charge_cost = 100

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/electrode(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/electrode(src)
						return 1
					return 0

		shockgun
			name = "shock gun"
			icon_state = "shockgun"
			//fire_sound_1 = 'gun_shockgun_1.ogg' // Let them be taser ones by now
			//fire_sound_2 = null
			charge_cost = 250

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/fireball(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		decloner
			name = "decloner"
			desc = "A high tech energy weapon that declones a target."
			icon_state = "decloner"
			fire_sound = 'pulse3.ogg'
			origin_tech = "combat=5;materials=4;powerstorage=3"
			charge_cost = 100

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/declone(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		stunrevolver
			name = "stun revolver"
			icon_state = "stunrevolver"
			fire_sound_1 = 'Gunshot.ogg' // revolver shooting stun bursts sounding like a gun? Oh well
			charge_cost = 125

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/electrode(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		freeze
			name = "freeze gun"
			icon_state = "freezegun"
			fire_sound = 'pulse3.ogg'
			desc = "A gun that shoots supercooled hydrogen particles to drastically chill a target's body temperature."
			var/temperature = T20C
			var/current_temperature = T20C
			charge_cost = 100
			origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				spawn()
					Life()

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/freeze(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				user.machine = src
				var/temp_text = ""
				if(temperature > (T0C - 50))
					temp_text = "<FONT color=black>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
				else
					temp_text = "<FONT color=blue>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"

				var/dat = {"<B>Freeze Gun Configuration: </B><BR>
				Current output temperature: [temp_text]<BR>
				Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
				"}

				user << browse(dat, "window=freezegun;size=450x300")
				onclose(user, "freezegun")

			Topic(href, href_list)
				if (..())
					return
				usr.machine = src
				src.add_fingerprint(usr)
				if(href_list["temp"])
					var/amount = text2num(href_list["temp"])
					if(amount > 0)
						src.current_temperature = min(T20C, src.current_temperature+amount)
					else
						src.current_temperature = max(0, src.current_temperature+amount)
				if (istype(src.loc, /mob))
					attack_self(src.loc)
				src.add_fingerprint(usr)
				return

			proc/Life()
				while(src)
					sleep(10)

					switch(temperature)
						if(0 to 10) charge_cost = 500
						if(11 to 50) charge_cost = 150
						if(51 to 100) charge_cost = 100
						if(101 to 150) charge_cost = 75
						if(151 to 200) charge_cost = 50
						if(201 to 300) charge_cost = 25

					if(current_temperature != temperature)
						var/difference = abs(current_temperature - temperature)
						if(difference >= 10)
							if(current_temperature < temperature)
								temperature -= 10
							else
								temperature += 10

						else
							temperature = current_temperature

						if (istype(src.loc, /mob))
							attack_self(src.loc)

		plasma
			name = "plasma gun"
			icon_state = "plasmagun"
			fire_sound = 'pulse3.ogg'
			desc = "A gun that fires super heated plasma at targets, thus increasing their overal body temparature and also harming them."
			var/temperature = T20C
			var/current_temperature = T20C
			charge_cost = 100
			origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"


			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				spawn()
					Life()


			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/plasma(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				user.machine = src
				var/temp_text = ""
				if(temperature < (T0C + 50))
					temp_text = "<FONT color=black>[temperature] ([round(temperature+T0C)]&deg;C) ([round(temperature*1.8+459.67)]&deg;F)</FONT>"
				else
					temp_text = "<FONT color=red>[temperature] ([round(temperature+T0C)]&deg;C) ([round(temperature*1.8+459.67)]&deg;F)</FONT>"

				var/dat = {"<B>Plasma Gun Configuration: </B><BR>
				Current output temperature: [temp_text]<BR>
				Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
				"}

				user << browse(dat, "window=plasmagun;size=450x300")
				onclose(user, "plasmagun")

			Topic(href, href_list)
				if (..())
					return
				usr.machine = src
				src.add_fingerprint(usr)
				if(href_list["temp"])
					var/amount = text2num(href_list["temp"])
					if(amount > 0)
						src.current_temperature = min(T20C, src.current_temperature+amount)
					else
						src.current_temperature = max(0, src.current_temperature+amount)
				if (istype(src.loc, /mob))
					attack_self(src.loc)
				src.add_fingerprint(usr)
				return

			proc/Life()
				while(src)
					sleep(10)

					switch(temperature)
						if(601 to 800) charge_cost = 500
						if(401 to 600) charge_cost = 150
						if(201 to 400) charge_cost = 100
						if(101 to 200) charge_cost = 75
						if(51 to 100) charge_cost = 50
						if(0 to 50) charge_cost = 25

					if(current_temperature != temperature)
						var/difference = abs(current_temperature + temperature)
						if(difference >= 10)
							if(current_temperature < temperature)
								temperature -= 10
							else
								temperature += 10

						else
							temperature = current_temperature

						if (istype(src.loc, /mob))
							attack_self(src.loc)

		crossbow
			name = "mini energy-crossbow"
			desc = "Some kind of hi-tech energy crossbow."
			icon_state = "crossbow"
			w_class = 2.0
			item_state = "crossbow"
			force = 4.0
			throw_speed = 2
			throw_range = 10
			m_amt = 2000
			origin_tech = "combat=2;magnets=2;syndicate=5"
			silenced = 1
			fire_sound_1 = 'Genhit.ogg' // same shit, different toilet
			fire_sound_2 = null // oh you got a nice..
			loudness = 25

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				charge()

			proc/charge()
				if(power_supply)
					if(power_supply.charge < power_supply.maxcharge) power_supply.give(100)
				spawn(50) charge()

			update_icon()
				return

			attack_self(mob/living/user as mob)
				return

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/bolt(src)
				power_supply.use(charge_cost)
				return 1

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/electrode(src)
						return 1
					return 0
	proc
		load_into_chamber()
			in_chamber = new /obj/item/projectile/weakbullet(src)
			return 1

		badmin_ammo() //CREEEEEED!!!!!!!!!
			switch(badmin)
				if(1)
					in_chamber = new /obj/item/projectile/electrode(src)
				if(2)
					in_chamber = new /obj/item/projectile/weakbullet(src)
				if(3)
					in_chamber = new /obj/item/projectile(src)
				if(4)
					in_chamber = new /obj/item/projectile/beam(src)
				if(5)
					in_chamber = new /obj/item/projectile/beam/pulse(src)
				else
					return 0
			/*if(!istype(src, /obj/item/weapon/gun/energy))
				var/obj/item/bullet/AB = new(get_turf(src))
				AB.name = "unidentifiable bullet casing"
				AB.desc = "This casing has the Central Command Insignia etched into the side."*/
			return 1

		special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
			return 1

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		if (flag)
			return //we're placing gun on the table or in a backpack -- rastaf0
		if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
			return
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M.mutations & CLOWN) && prob(50))
				M << "\red The [src.name] blows up in your face."
				M.take_organ_damage(0,20)
				M.drop_item()
				del(src)
				return
		if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon/robot) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
			usr << "\red You don't have the dexterity to do this!"
			return

		add_fingerprint(user)
		var/i

		for(i = 0, i < projectiles_per_shot, i++)
			var/turf/curloc = user.loc
			var/turf/targloc = get_turf(target)
			if (!istype(targloc) || !istype(curloc))
				return

			if(badmin)
				badmin_ammo()
			else if(!special_check(user))
				return
			else if(!load_into_chamber())
				user << "\red *click* *click*";
				for(var/mob/O in hearers(user, null))
					playsound(user, 'guns_click_click.ogg', loudness, 1)
				return
				
			if(istype(src, /obj/item/weapon/gun/projectile/shotgun))
			var/obj/item/weapon/gun/projectile/shotgun/S = src
			if(S.pumped >= S.maxpump)
				S.pump()
				return

			update_icon()
			
			for(var/mob/O in hearers(user, null))
				if(fire_sound_3)
					switch(rand(1,3))
						if(1) playsound(user, fire_sound_1, loudness, 1)
						if(2) playsound(user, fire_sound_2, loudness, 1)
						if(3) playsound(user, fire_sound_3, loudness, 1)
				else if(fire_sound_2)
					switch(rand(1,2))
						if(1) playsound(user, fire_sound_1, loudness, 1)
						if(2) playsound(user, fire_sound_2, loudness, 1)
				else if(fire_sound_1)
					playsound(user, fire_sound_1, loudness, 1)
				else playsound(user, fire_sound, loudness, 1)

			if(!in_chamber)
				return

			in_chamber.firer = user
			in_chamber.def_zone = user.get_organ_target()

			if(targloc == curloc)
				user.bullet_act(in_chamber)
				del(in_chamber)
			else
				in_chamber.original = targloc
				in_chamber.loc = get_turf(user)
				user.next_move = world.time + 4
				in_chamber.silenced = silenced
				in_chamber.current = curloc
				in_chamber.yo = targloc.y - curloc.y
				in_chamber.xo = targloc.x - curloc.x
				spawn()
					in_chamber.process()
				sleep(1)
				in_chamber = null

				if(istype(src, /obj/item/weapon/gun/projectile/shotgun))
					var/obj/item/weapon/gun/projectile/shotgun/S = src
					S.pumped++
//