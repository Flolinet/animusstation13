/obj/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			if (occupied)
				new /obj/item/weapon/gun/energy/laser/captain( src.loc )
				occupied = 0
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()

/obj/displaycase/bullet_act(flag)

	if (flag == PROJECTILE_BULLET)
		src.health -= 10
		src.healthcheck()
		return
	if (flag == PROJECTILE_BULLETBURST)
		src.health -= 4
		src.healthcheck()
		return
	if (flag != PROJECTILE_LASER) //lasers aren't particularly good at breaking glass
		src.health -= 2
		src.healthcheck()
		return
	if (flag != PROJECTILE_SHOCK)
		src.health -= 4
		src.healthcheck()
		return
	else
		src.health -= 5
		src.healthcheck()
		return


/obj/displaycase/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		if (occupied)
			new /obj/item/weapon/gun/energy/laser/captain( src.loc )
			occupied = 0
		del(src)


/obj/displaycase/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		new /obj/item/weapon/gun/energy/laser/captain( src.loc )
		del(src)


/obj/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			update_icon()
	else
		playsound(src.loc, 'Glasshit.ogg', 75, 1)
	return

/obj/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return


/obj/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/displaycase/attack_hand(mob/user as mob)
	if (src.destroyed && src.occupied)
		new /obj/item/weapon/gun/energy/laser/captain( src.loc )
		user << "\b You deactivate the hover field built into the case."
		src.occupied = 0
		src.add_fingerprint(user)
		update_icon()
		return
	else
		usr << text("\blue You kick the display case.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the display case.", usr)
		src.health -= 2
		healthcheck()
		return


