//Banhammer deserves to be the first thing here

/obj/item/weapon/banhammer/attack(mob/M as mob, mob/user as mob)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"

/obj/mine/proc/triggerrad(obj)
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 50
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		del(src)

/obj/mine/proc/triggerstun(obj)
	obj:stunned += 30
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		del(src)

/obj/mine/proc/triggern2o(obj)
	//example: n2o triggerproc
	//note: im lazy

	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			if(target.parent)
				target.parent.suspend_group_processing()

			var/datum/gas_mixture/payload = new
			var/datum/gas/sleeping_agent/trace_gas = new

			trace_gas.moles = 30
			payload += trace_gas

			target.air.merge(payload)

	spawn(0)
		del(src)

/obj/mine/proc/triggerplasma(obj)
	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			if(target.parent)
				target.parent.suspend_group_processing()

			var/datum/gas_mixture/payload = new

			payload.toxins = 30

			target.air.merge(payload)

			target.hotspot_expose(1000, CELL_VOLUME)

	spawn(0)
		del(src)

/obj/mine/proc/triggerkick(obj)
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(obj:client)
	spawn(0)
		del(src)

/obj/mine/proc/explode(obj)
	explosion(loc, 0, 1, 2, 3)
	spawn(0)
		del(src)


/obj/mine/HasEntered(AM as mob|obj)
	Bumped(AM)

/obj/mine/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << text("<font color='red'>[M] triggered the \icon[] [src]</font>", src)
		triggered = 1
		call(src,triggerproc)(M)

/obj/mine/New()
	icon_state = "uglyminearmed"

/obj/item/assembly/proc/c_state(n, O as obj)
	return

//*****RM

/obj/item/assembly/time_ignite/premade/New()
	..()
	part1 = new(src)
	part2 = new(src)
	part1.master = src
	part2.master = src
	//part2.status = 0

/obj/item/assembly/time_ignite/Del()
	del(part1)
	del(part2)
	..()

/obj/item/assembly/time_ignite/attack_self(mob/user as mob)
	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/receive_signal()
	if (!status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/decal/ash/attack_hand(mob/user as mob)
	usr << "\blue The ashes slip through your fingers."
	del(src)
	return

/obj/item/assembly/time_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null

		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The timer is now secured!", 1)
	else
		user.show_message("\blue The timer is now unsecured!", 1)
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/c_state(n)
	src.icon_state = text("timer-igniter[]", n)
	return

//***********

/obj/item/assembly/anal_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null

		del(src)
		return
	if (( istype(W, /obj/item/weapon/screwdriver) ))
		src.status = !( src.status )
		if (src.status)
			user.show_message("\blue The analyzer is now secured!", 1)
		else
			user.show_message("\blue The analyzer is now unsecured!", 1)
		src.part2.status = src.status
		src.add_fingerprint(user)
	if(( istype(W, /obj/item/clothing/suit/armor/vest) ) && src.status)
		var/obj/item/assembly/a_i_a/R = new
		R.part1 = part1
		R.part1.master = R
		part1 = null

		R.part2 = part2
		R.part2.master = R
		part2 = null

		user.put_in_hand(R)
		user.before_take_item(W)
		R.part3 = W
		R.part3.master = R
		del(src)

/* WTF THIS SHIT? It is working? Shouldn't. --rastaf0
		W.loc = R
		R.part1 = W
		R.part2 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)
*/
	return
/*	else if ((istype(W, /obj/item/device/timer) && !( src.status )))

		var/obj/item/assembly/time_ignite/R = new /obj/item/assembly/time_ignite( user )
		W.loc = R
		R.part1 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part2 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)
*/
/obj/item/assembly/a_i_a/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null
		src.part3.loc = T
		src.part3.master = null
		src.part3 = null

		del(src)
		return
	if (( istype(W, /obj/item/weapon/screwdriver) ))
		if (!src.status && (!part1||!part2||!part3))
			user << "\red You cannot finish the assembly, not all components are in place!"
			return
		src.status = !( src.status )
		if (src.status)
			user.show_message("\blue The armor is now secured!", 1)
		else
			user.show_message("\blue The armor is now unsecured!", 1)
		src.add_fingerprint(user)

/obj/item/assembly/a_i_a/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	del(src.part3)
	..()
	return
//*****

/obj/item/assembly/rad_time/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_time/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The signaler is now secured!", 1)
	else
		user.show_message("\blue The signaler is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/receive_signal(datum/signal/signal)
	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return
//*******************
/obj/item/assembly/rad_prox/c_state(n)
	src.icon_state = "prox-radio[n]"
	return

/obj/item/assembly/rad_prox/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_prox/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12)
		src.part2.sense()
	return

/obj/item/assembly/rad_prox/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/receive_signal(datum/signal/signal)
	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_prox/Move()
	..()
	src.part2.sense()
	return

/obj/item/assembly/rad_prox/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/assembly/rad_prox/dropped()
	spawn( 0 )
		src.part2.sense()
		return
	return
//************************
/obj/item/assembly/rad_infra/c_state(n)
	src.icon_state = text("infrared-radio[]", n)
	return

/obj/item/assembly/rad_infra/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_infra/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The infrared laser is now secured!", 1)
	else
		user.show_message("\blue The infrared laser is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/receive_signal(datum/signal/signal)

	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_infra/verb/rotate()
	set name = "Rotate Assembly"
	set category = "Object"
	set src in usr

	src.dir = turn(src.dir, 90)
	src.part2.dir = src.dir
	src.add_fingerprint(usr)
	return

/obj/item/assembly/rad_infra/Move()

	var/t = src.dir
	..()
	src.dir = t
	//src.part2.first = null
	del(src.part2.first)
	return

/obj/item/assembly/rad_infra/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/assembly/rad_infra/attack_hand(M)
	del(src.part2.first)
	..()
	return

/obj/item/assembly/prox_ignite/HasProximity(atom/movable/AM as mob|obj)

	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return

/obj/item/assembly/prox_ignite/dropped()
	spawn( 0 )
		src.part1.sense()
		return
	return

/obj/item/assembly/prox_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/assembly/prox_ignite/c_state(n)
	src.icon_state = text("prox-igniter[]", n)
	return

/obj/item/assembly/prox_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured! The igniter will not work.", 1)
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/receive_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/item/assembly/rad_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/weapon/directions/attack_hand(mob/user as mob)
	if (istype(usr, /mob/living/carbon/human))
		if (prob(50))
			usr << "\blue You try to read the paper, but it breaks apart in your hand. Must have been pretty old.."
			del(src)
			return
		else
			if (user.knowledge < 1)
				usr << "\red As you read over the paper, you slowly realize what you are reading. You quickly memorize the words on the paper before it breaks apart in your hand, and slips through your fingers."
				user.knowledge++
				del(src)
				return
			else
				usr << "\blue You already have read this paper."
				return
		return

/obj/item/assembly/rad_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The radio is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The radio is now unsecured! The igniter will not work.", 1)
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/receive_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/item/assembly/m_i_ptank/c_state(n)

	src.icon_state = text("prox-igniter-tank[]", n)
	return

/obj/item/assembly/m_i_ptank/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return


//*****RM
/obj/item/assembly/m_i_ptank/Bump(atom/O)
	spawn(0)
		//world << "miptank bumped into [O]"
		if(src.part1.state)
			//world << "sending signal"
			receive_signal()
		else
			//world << "not active"
	..()

/obj/item/assembly/m_i_ptank/proc/prox_check()
	if(!part1 || !part1.state)
		return
	for(var/atom/A in view(1, src.loc))
		if(A!=src && !istype(A, /turf/space) && !isarea(A))
			//world << "[A]:[A.type] was sensed"
			src.part1.sense()
			break

	spawn(10)
		prox_check()


//*****


/obj/item/assembly/m_i_ptank/dropped()

	spawn( 0 )
		part1.sense()
		return
	return

/obj/item/assembly/m_i_ptank/examine()
	..()
	part3.examine()

/obj/item/assembly/m_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/m_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/prox_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool)&&W:welding ))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/m_i_ptank/attack_self(mob/user as mob)

	playsound(src.loc, 'armbomb.ogg', 100, 1)
	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/m_i_ptank/receive_signal()
	//world << "miptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)

	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
			src.part1.state = 0.0

	return

/obj/item/assembly/m_i_ptank/emp_act(severity)

	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()

//*****RM

/obj/item/assembly/t_i_ptank/c_state(n)

	src.icon_state = text("timer-igniter-tank[]", n)
	return

/obj/item/assembly/t_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/assembly/t_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/t_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/time_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		if(src)
			src.status = 0
			bombers += "[key_name(user)] unwelded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]"
			user << "\blue The hole has been closed."
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/t_i_ptank/attack_self(mob/user as mob)

	src.part1.attack_self(user, 1)
	playsound(src.loc, 'armbomb.ogg', 100, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/t_i_ptank/receive_signal()
	//world << "tiptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return

/obj/item/assembly/t_i_ptank/emp_act(severity)
	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()

/obj/item/assembly/r_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/assembly/r_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/r_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/rad_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding ))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/emp_act(severity)
	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()

//*****RM

/obj/item/clothing/suit/armor/a_i_a_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/device/analyzer))
		src.part4.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/a_i_a/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		R.part3 = src.part3
		R.part3.master = R
		R.part3.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part4)
		else
			part4.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		src.part4 = null
		del(src)
		return
	if (( istype(W, /obj/item/weapon/weldingtool) && W:welding))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
//	src.part3.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/attack_self(mob/user as mob)
	playsound(src.loc, 'armbomb.ogg', 100, 1)
	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/receive_signal()
	//world << "riptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return

/obj/beam/i_beam/proc/hit()
	//world << "beam \ref[src]: hit"
	if (src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.hit()
	//SN src = null
	del(src)
	return

/obj/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	src.visible = v
	spawn( 0 )
		if (src.next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/beam/i_beam/proc/process()
	//world << "i_beam \ref[src] : process"

	if ((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0


	//world << "now [src.left] left"
	var/obj/beam/i_beam/I = new /obj/beam/i_beam( src.loc )
	I.master = src.master
	I.density = 1
	I.dir = src.dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if (I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if (!( src.next ))
			//world << "no src.next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(src.visible)
			src.next = I
			spawn( 0 )
				//world << "limit = [src.limit] "
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			//I = null
			del(I)
	else
		//src.next = null
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn( 10 )
		src.process()
		return
	return

/obj/beam/i_beam/Bump()
	del(src)
	return

/obj/beam/i_beam/Bumped()
	src.hit()
	return

/obj/beam/i_beam/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/beam/i_beam/Del()
	del(src.next)
	..()
	return

/atom/proc/ex_act()
	return

/atom/proc/blob_act()
	return

// bullet_act called when anything is hit buy a projectile (bullet, tazer shot, laser, etc.)
// flag is projectile type, can be:
//PROJECTILE_TASER = 1   		taser gun
//PROJECTILE_LASER = 2			laser gun
//PROJECTILE_BULLET = 3			traitor pistol
//PROJECTILE_PULSE = 4			pulse rifle
//PROJECTILE_BOLT = 5			crossbow
//PROJECTILE_WEAKBULLET = 6		detective's revolver

/atom/proc/bullet_act(flag)
	if(flag == PROJECTILE_PULSE)
		src.ex_act(2)
	return


/turf/Entered(atom/A as mob|obj)
	..()
	if ((A && A.density && !( istype(A, /obj/beam) )))
		for(var/obj/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				return
	return

/obj/item/weapon/mousetrap/examine()
	set src in oview(12)
	..()
	if(armed)
		usr << "\red It looks like it's armed."

/obj/item/weapon/mousetrap/proc/triggered(mob/target as mob, var/type = "feet")
	if(!armed)
		return
	var/datum/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.organs[pick("l_foot", "r_foot")]
					H.weakened = max(3, H.weakened)
			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.organs[type]
					H.stunned = max(3, H.stunned)
		if(affecting)
			affecting.take_damage(1, 0)
			H.UpdateDamageIcon()
			H.updatehealth()
	playsound(target.loc, 'snap.ogg', 50, 1)
	icon_state = "mousetrap"
	armed = 0
/*
	else if (ismouse(target))
		target.bruteloss = 100
*/

/obj/item/weapon/mousetrap/attack_self(mob/user as mob)
	if(!armed)
		icon_state = "mousetraparmed"
		user << "\blue You arm the mousetrap."
	else
		icon_state = "mousetrap"
		if((user.brainloss >= 60 || user.mutations & CLOWN) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message(text("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>"), 1)
			return
		user << "\blue You disarm the mousetrap."
	armed = !armed
	playsound(user.loc, 'handcuffs.ogg', 30, 1, -3)

/obj/item/weapon/mousetrap/attack_hand(mob/user as mob)
	if(armed)
		if((user.brainloss >= 60 || user.mutations & CLOWN) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message(text("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>"), 1)
			return
	..()

/obj/item/weapon/mousetrap/HasEntered(AM as mob|obj)
	if((ishuman(AM)) && (armed))
		var/mob/living/carbon/H = AM
		if(H.m_intent == "run")
			src.triggered(H)
			H << "\red <B>You accidentally step on the mousetrap!</B>"
			for(var/mob/O in viewers(H, null))
				if(O == H)
					continue
				O.show_message(text("\red <B>[H] accidentally steps on the mousetrap.</B>"), 1)
	..()

/obj/item/weapon/mousetrap/hitby(A as mob|obj)
	if(!armed)
		return ..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>The mousetrap is triggered by [A].</B>"), 1)
	src.triggered(null)
