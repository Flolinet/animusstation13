/mob/living/carbon/metroid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "baby metroid")
		name = text("baby metroid ([rand(1, 1000)])")
	else
		name = text("adult metroid ([rand(1,1000)])")

	real_name = name
	spawn (1)
		update_clothing()
		src << "\blue Your icons have been generated!"
	..()

/mob/living/carbon/metroid/proc/mind_initialize(mob/G)
	mind = new
	mind.current = src
	mind.assigned_role = "Metroid"
	//mind.special_role = alien_caste
	mind.key = G.key

/mob/living/carbon/metroid/movement_delay()
	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("hyperzine")) // hyperzine slows Metroids down
			tally *= 2 // moves twice as slow

		if(reagents.has_reagent("frostoil")) // frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the metroid moves twice as slow
		tally *= 2

	if (bodytemperature >= 330.23) // 135 F
		return -1	// Metroids become supercharged at high temperatures

	return tally


/mob/living/carbon/metroid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1

		if(isobj(AM))
			if(!client && powerlevel > 0)
				var/probab = 10
				switch(powerlevel)
					if(1 to 2) probab = 20
					if(3 to 4) probab = 30
					if(5 to 6) probab = 40
					if(7 to 8) probab = 60
					if(9) 	   probab = 70
					if(10) 	   probab = 95
				if(prob(probab) || Charging)
					if(Charging) Charging = null

					if(istype(AM, /obj/window) || istype(AM, /obj/grille))
						if(istype(src, /mob/living/carbon/metroid/adult))
							if(nutrition <= 600 && !Atkcool)
								AM.attack_metroid(src)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0
						else
							if(nutrition <= 500 && !Atkcool)
								if(prob(5))
									if(prob(50))
										AM.attack_metroid(src)
										spawn()
											Atkcool = 1
											sleep(15)
											Atkcool = 0

		if(ismob(AM))
			var/mob/tmob = AM

			if(istype(src, /mob/living/carbon/metroid/adult))
				if(istype(tmob, /mob/living/carbon/human))
					if(prob(90))
						now_pushing = 0
						return
			else
				if(istype(tmob, /mob/living/carbon/human))
					now_pushing = 0
					return

		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return


/mob/living/carbon/metroid/Stat()
	..()

	statpanel("Status")
	if(istype(src, /mob/living/carbon/metroid/adult))
		stat(null, "Health: [round((health / 200) * 100)]%")
	else
		stat(null, "Health: [round((health / 150) * 100)]%")


	if (client.statpanel == "Status")
		if(istype(src,/mob/living/carbon/metroid/adult))
			stat(null, "Nutrition: [nutrition]/1200")
			if(amount_grown >= 10)
				stat(null, "You can reproduce!")
		else
			stat(null, "Nutrition: [nutrition]/1000")
			if(amount_grown >= 10)
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")


/mob/living/carbon/metroid/bullet_act(flag, A as obj)
	if(A)
		if (locate(/obj/item/weapon/grab, src))
			var/mob/safe = null
			if (istype(l_hand, /obj/item/weapon/grab))
				var/obj/item/weapon/grab/G = l_hand
				if ((G.state == 3 && get_dir(src, A) == dir))
					safe = G.affecting
			if (istype(r_hand, /obj/item/weapon/grab))
				var/obj/item/weapon.grab/G = r_hand
				if ((G.state == 3 && get_dir(src, A) == dir))
					safe = G.affecting
			if (safe)
				return safe.bullet_act(flag, A)

	switch(flag)
		if(PROJECTILE_BULLET)
			var/d = 1

			attacked += 10
			if (stat != 2)
				bruteloss += d

				updatehealth()
			return
		if(PROJECTILE_BULLETBURST)
			var/d = 1

			attacked += 10
			if (stat != 2)
				bruteloss += d

				updatehealth()
			return
		if(PROJECTILE_WEAKBULLETBURST)
			var/d = 1

			attacked += 10
			if (stat != 2)
				bruteloss += d

				updatehealth()
			return
		if(PROJECTILE_WEAKERBULLETBURST)
			var/d = 0.5

			attacked += 10
			if (stat != 2)
				bruteloss += d

				updatehealth()
			return
		if(PROJECTILE_TASER)
			if (prob(70))
				powerlevel++
				if(powerlevel > 10) powerlevel = 10

		if(PROJECTILE_LASER)
			var/d = 30

			attacked += 10
	//		if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff./ It really doesn't make any sense. /N

			if (stat != 2)
				bruteloss += d

				updatehealth()
		if(PROJECTILE_SHOCK)
			var/d = 30

			attacked += 10
			if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff./ It really doesn't make any sense. /N

			if (stat != 2)
				bruteloss += d

				updatehealth()

			if (prob(70))
				powerlevel++
				if(powerlevel > 10) powerlevel = 10
		if(PROJECTILE_PULSE)
			var/d = 100

			attacked += 10
			if (stat != 2)
				bruteloss += d

				updatehealth()
	return


/mob/living/carbon/metroid/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/metroid/ex_act(severity)

	if (stat == 2 && client)
		return

	else if (stat == 2 && !client)
		del(src)
		return

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			return

		if (2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	bruteloss += b_loss
	fireloss += f_loss

	updatehealth()


/mob/living/carbon/metroid/blob_act()
	if (stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The magma splashes on you!")

	fireloss += damage

	updatehealth()
	return


/mob/living/carbon/metroid/u_equip(obj/item/W as obj)
	return


/mob/living/carbon/metroid/db_click(text, t1)
	return

/mob/living/carbon/metroid/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		bruteloss += (istype(O, /obj/meteor/small) ? 10 : 25)
		fireloss += 30

		updatehealth()
	return


/mob/living/carbon/metroid/Move(a, b, flag)

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at __LINE__ in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return



/mob/living/carbon/metroid/update_clothing()
	..()

	if (monkeyizing)
		return


	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null


	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return



/mob/living/carbon/metroid/attack_metroid(mob/living/carbon/metroid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] has bit []!</B>", src), 1)

		var/damage = rand(1, 3)
		attacked += 5

		if(istype(src, /mob/living/carbon/metroid/adult))
			damage = rand(1, 6)
		else
			damage = rand(1, 3)

		bruteloss += damage


		updatehealth()

	return

/mob/living/carbon/metroid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	..()

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)
		else
			if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (health > 0)
				attacked += 10
				playsound(loc, 'bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
				bruteloss  += rand(1, 3)
				updatehealth()
	return


/mob/living/carbon/metroid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off!", 1)
				playsound(loc, 'punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off!", 1)
				playsound(loc, 'thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				Victim = null
				anchored = 0
				step_away(src,M)

			return

		else
			if(prob(30))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!istype(src, /mob/living/carbon/metroid/adult))
						if(Discipline == 1)
							attacked = 0


				Victim = null
				anchored = 0
				step_away(src,M)

			return



	if(M.gloves && M.gloves.elecgen == 1)//Stungloves. Any contact will stun the alien.
		if(M.gloves.uses > 0)
			M.gloves.uses--
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall.", 2)

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		else
			var/damage = rand(1, 9)

			attacked += 10
			if (prob(90))
				if (M.mutations & HULK)
					damage += 5
					if(Victim)
						Victim = null
						anchored = 0
						if(prob(80) && !client)
							Discipline++
					spawn(0)

						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)


				playsound(loc, "punch", 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

				bruteloss += damage
				updatehealth()
			else
				playsound(loc, 'punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
	return



/mob/living/carbon/metroid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)
		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)

		if ("hurt")

			if ((prob(95) && health > 0))
				attacked += 10
				playsound(loc, 'slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has slashed [name]!</B>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has wounded [name]!</B>", M), 1)
				bruteloss += damage
				updatehealth()
			else
				playsound(loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to lunge at [name]!</B>", M), 1)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [name] passively!", M), 1)

		if ("disarm")
			playsound(loc, 'pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			if(prob(95))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled [name]!</B>", M), 1)

				if(Victim)
					Victim = null
					anchored = 0
					if(prob(80) && !client)
						Discipline++
						if(!istype(src, /mob/living/carbon/metroid))
							if(Discipline == 1)
								attacked = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
			bruteloss += damage
			updatehealth()
	return


/mob/living/carbon/metroid/restrained()
	return 0


mob/living/carbon/metroid/var/co2overloadtime = null
mob/living/carbon/metroid/var/temperature_resistance = T0C+75


/mob/living/carbon/metroid/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

/mob/living/carbon/metroid/updatehealth()
	if (nodamage == 0)
		// metroids can't suffocate unless they suicide. They are also not harmed by fire
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200 - (oxyloss + toxloss + fireloss + bruteloss + cloneloss)
		else
			health = 150 - (oxyloss + toxloss + fireloss + bruteloss + cloneloss)
	else
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200
		else
			health = 150
		stat = 0