/datum/disease/wizarditis
	name = "Wizarditis"
	max_stages = 4
	spread = "Airborne"
	cure = "The Manly Dorf"
	cure_id = "manlydorf"
	agent = "Rincewindus Vulgaris"
	affected_species = list("Human")
	curable = 0
	permeability_mod = 0.75
	desc = "Some speculate, that this virus is the cause of Wizard Federation existance. Subjects affected show the signs of mental retardation, yelling obscure sentences or total gibberish. On late stages subjects sometime express the feelings of inner power, and, cite, 'the ability to control the forces of cosmos themselves!' A gulp of strong, manly spirits usually reverts them to normal, humanlike, condition."
	severity = "Minor"

/*
BIRUZ BENNAR
SCYAR NILA - teleport
NEC CANTIO - dis techno
EI NATH - shocking grasp
AULIE OXIN FIERA - knock
TARCOL MINTI ZHERI - forcewall
STI KALY - blind
*/

/datum/disease/wizarditis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(4))
				affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"))
			if(prob(2))
				affected_mob << "\red You feel [pick("that you don't have enough mana.", "that the winds of magic are gone.", "an urge to summon familiar.")]"


		if(3)
			spawn_wizard_clothes(5)
			if(prob(4))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(2))
				affected_mob << "\red You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar.")]."

		if(4)
			spawn_wizard_clothes(10)
			if(prob(4))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"))
				return
			if(prob(2))
				affected_mob << "\red You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")]."
			if(prob(2))
				teleport()

	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(var/chance=5)
	if(istype(affected_mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = affected_mob
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(H.head)
					H.drop_from_slot(H.head)
				H.head = new /obj/item/clothing/head/wizard(H)
				H.head.layer = 20
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(H.wear_suit)
					H.drop_from_slot(H.wear_suit)
				H.wear_suit = new /obj/item/clothing/suit/wizrobe(H)
				H.wear_suit.layer = 20
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(H.shoes)
					H.drop_from_slot(H.shoes)
				H.shoes = new /obj/item/clothing/shoes/sandal(H)
				H.shoes.layer = 20
			return
	else
		var/mob/living/carbon/H = affected_mob
		if(prob(chance))
			if(!istype(H.r_hand, /obj/item/weapon/staff))
				if(H.r_hand)
					H.drop_from_slot(H.r_hand)
				H.r_hand = new /obj/item/weapon/staff(H)
				H.r_hand.layer = 20
			return
	return



/datum/disease/wizarditis/proc/teleport()
/*
	var/list/theareas = new/list()
	for(var/area/AR in world)
		if(theareas.Find(AR)) continue
		var/turf/picked = pick(get_area_turfs(AR.type)
		if (picked && picked.z == affected_mob.z)
			theareas += AR

	var/area/thearea = pick(theareas)
*/

	var/list/theareas = new/list()
	for(var/area/AR in orange(80, affected_mob))
		if(theareas.Find(AR) || AR.name == "Space") continue
		theareas += AR

	if(!theareas)
		return

	var/area/thearea = pick(theareas)

	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, affected_mob.loc)
	smoke.attach(affected_mob)
	smoke.start()

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != affected_mob.z) continue
		if(T.name == "space") continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L)
		return

	affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!")
	affected_mob.loc = pick(L)
	smoke.start()
//Apparently it created a lagspike every time it was called -- Urist
	return
