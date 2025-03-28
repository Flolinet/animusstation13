/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/send_hear()
	if (!(src.wires & WIRE_RECEIVE))
		return
	if (!src.listening)
		return 

	var/turf/T = get_turf(src)
	var/list/hear = hearers(7, T)
	var/list/V
	//find mobs in lockers, cryo and intellycards
	for (var/mob/M in world)
		if (isturf(M.loc))
			continue //if M can hear us it is already was found by hearers()
		if (!M.client)
			continue //skip monkeys and leavers
		if (!V) //lasy initialisation
			V = view(7, T)
		if (get_turf(M) in V) //this slow, but I don't think we'd have a lot of wardrobewhores every round --rastaf0
			hear+=M
	return hear

/obj/item/device/radio/intercom/hear_talk(mob/M as mob, msg)
	if(!src.anyai && !(M in src.ai))
		return
	..()