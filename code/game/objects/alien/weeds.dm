/obj/alien/weeds/New()
	..()
	if(istype(loc, /turf/space))
		del(src)
		return
	icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150,300))
		if(src)
			Life()
	return

/obj/alien/weeds/proc/Life()
	var/turf/U = get_turf(src)
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		health -= round(U.poison/200000)
		update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/alien/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

	//		if (locate(/obj/movable, T)) // don't propogate into movables
	//			continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/alien/weeds(T)


/obj/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(5))
				del(src)
	return

/obj/alien/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	visible_message("\red <B>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.welding)
			damage = 15
			playsound(loc, 'Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)


/obj/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/*/obj/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/