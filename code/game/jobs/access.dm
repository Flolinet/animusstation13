/var/const
	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_medlab = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44
	access_surgery = 45
	access_theatre = 46
	access_research = 47
	access_mining = 48
	access_mining_office = 49 //not in use
	access_mailsorting = 50
	access_mint = 51
	access_mint_vault = 52
	access_heads_vault = 53
	access_mining_station = 54
	access_xenobiology = 55
	access_ce = 56
	access_hop = 57
	access_hos = 58
	access_RC_announce = 59 //Request console announcements

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
	Mostly for admin fun times.*/
	access_cent_general = 101//General facilities.
	access_cent_thunder = 102//Thunderdome.
	access_cent_specops = 103//Special Ops.
	access_cent_medical = 104//Medical/Research
	access_cent_living = 105//Living quarters.
	access_cent_storage = 106//Generic storage areas.
	access_cent_teleporter = 107//Teleporter.
	access_cent_creed = 108//Creed's office.
	access_cent_captain = 109//Captain's office/ID comp/AI.

	//MONEY
	access_crate_cash = 200

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/New()
	//NOTE: If a room requires more than one access (IE: Morgue + medbay) set the req_acesss_txt to "5;6" if it requires 5 and 6
	if(src.req_access_txt)
		var/list/req_access_str = dd_text2list(req_access_txt,";")
		if(!req_access)
			req_access = list()
		for(var/x in req_access_str)
			var/n = text2num(x)
			if(n)
				req_access += n
	..()

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/silicon))
		//AI can do whatever he wants
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(george.equipped() && (istype(george.equipped(), /obj/item/weapon/card/id) || istype(george.equipped(), /obj/item/device/pda)) && src.check_access(george.equipped()))
			return 1
	return 0

/obj/proc/check_access(obj/item/weapon/card/id/I)

	if (istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id

	if(!src.req_access) //no requirements
		return 1
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/proc/get_access(job)
	switch(job)
		if("Geneticist")
			return list(access_medical, access_morgue, access_medlab)
		if("Station Engineer")
			return list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks)
		if("Assistant")
			return list(access_maint_tunnels)
		if("Chaplain")
			return list(access_morgue, access_chapel_office, access_crematorium)
		if("Detective")
			return list(access_security, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
		if("Medical Doctor")
			return list(access_medical, access_morgue, access_surgery)
		if("Botanist")	// -- TLE
			return list(access_hydroponics) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT
		if("Librarian") // -- TLE
			return list(access_library)
		if("Lawyer") //Muskets 160910
			return list(access_maint_tunnels, access_lawyer, access_court)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(access_security, access_brig, access_court)
		if("Warden")
			return list(access_security, access_brig, access_armory, access_court)
		if("Scientist")
			return list(access_tox, access_tox_storage, access_research, access_medical, access_xenobiology)
		if("Head of Security")
			return list(access_medical, access_morgue, access_tox, access_tox_storage, access_chemistry, access_medlab, access_court,
			            access_teleporter, access_heads, access_tech_storage, access_security, access_brig, access_atmospherics,
			            access_maint_tunnels, access_bar, access_janitor, access_kitchen, access_robotics, access_armory, access_hydroponics,
			            access_theatre, access_research, access_hos, access_RC_announce)
		if("Head of Personnel")
			return list(access_security, access_brig, access_court, access_forensics_lockers,
			            access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab, access_engine,
			            access_emergency_storage, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
			            access_crematorium, access_kitchen, access_robotics, access_cargo, access_cargo_bot, access_hydroponics, access_lawyer,
			            access_theatre, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_hop, access_RC_announce)
		if("Atmospheric Technician")
			return list(access_atmospherics, access_maint_tunnels, access_emergency_storage)
		if("Bartender")
			return list(access_bar)
		if("Chemist")
			return list(access_medical, access_chemistry)
		if("Janitor")
			return list(access_janitor, access_maint_tunnels)
		if("Clown")
			return list(access_maint_tunnels, access_clown, access_theatre)
		if("Mime")
			return list(access_maint_tunnels, access_mime, access_theatre)
		if("Chef")
			return list(access_kitchen, access_morgue)
		if("Roboticist")
			return list(access_robotics, access_tech_storage, access_maint_tunnels)
		if("Cargo Technician")
			return list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
		if("Shaft Miner")
			return list(access_maint_tunnels, access_mining, access_mint, access_mining_station)
		if("Quartermaster")
			return list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining)
		if("Chief Engineer")
			return list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_ai_upload, access_construction, access_robotics,
			            access_mint, access_ce, access_RC_announce)
		if("Research Director") // removed hydroponics access, they are a supply field, not science
			return list(access_medical, access_morgue, access_medlab, access_rd,
			            access_tech_storage, access_maint_tunnels, access_heads, access_tox,
			            access_tox_storage, access_chemistry, access_teleporter, access_virology,
			            access_research, access_robotics, access_xenobiology, access_RC_announce)
		if("Virologist")
			return list(access_medical, access_morgue, access_virology, access_research)
		if("Chief Medical Officer")
			return list(access_medical, access_morgue, access_medlab, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery,
			access_research, access_RC_announce)
		else
			return list()

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Intel Officer")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("BlackOps Commander")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage, access_cent_creed)
		if("Supreme Commander")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(access_security, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_medlab, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_emergency_storage, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_cargo_bot, access_construction,
	            access_hydroponics, access_library, access_manufacturing, access_lawyer, access_virology, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting, access_mint_vault, access_mint,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(2) //medbay
			return list(access_medical, access_medlab, access_morgue, access_chemistry, access_virology, access_cmo, access_surgery)
		if(3) //research
			return list(access_tox, access_tox_storage, access_rd, access_hydroponics, access_manufacturing, access_research, access_xenobiology)
		if(4) //engineering and maintenance
			return list(access_engine, access_engine_equip, access_maint_tunnels, access_external_airlocks, access_emergency_storage, access_tech_storage, access_atmospherics, access_construction, access_robotics, access_ce)
		if(5) //command
			return list(access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_mint_vault, access_heads_vault, access_hop, access_RC_announce)
		if(6) //station general
			return list(access_chapel_office, access_kitchen,access_bar, access_janitor, access_crematorium, access_library, access_theatre, access_lawyer, access_clown, access_mime)
		if(7) //supply
			return list(access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station, access_mailsorting, access_mint)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Security"
		if(2) //medbay
			return "Medbay"
		if(3) //research
			return "Research"
		if(4) //engineering and maintenance
			return "Engineering"
		if(5) //command
			return "Command"
		if(6) //station general
			return "Station General"
		if(7) //supply
			return "Supply"


/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Cargo Bot Delivery"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Brig"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_medlab)
			return "Med-Sci"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "Toxins Research"
		if(access_tox_storage)
			return "Toxins Storage"
		if(access_chemistry)
			return "Toxins Chemical Lab"
		if(access_rd)
			return "RD Private"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Janitorial Equipment"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Engine & Power Control Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlock"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Head's Quarters/Bridge"
		if(access_captain)
			return "Captain's Quarters"
		if(access_all_personal_lockers)
			return "Personal Locker"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Site"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "Law Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_cmo)
			return "CMO Private"
		if(access_qm)
			return "Quartermaster's Office"
		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"
		if(access_surgery)
			return "Operating Room"
		if(access_theatre)
			return "Theatre"
		if(access_research)
			return "Research"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Delivery Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining Station"
		if(access_xenobiology)
			return "Xenobiology"
		if(access_hop)
			return "HoP Private"
		if(access_hos)
			return "HoS Private"
		if(access_ce)
			return "CE Private"
		if(access_RC_announce)
			return "Request console announcements"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "Code Grey"
		if(access_cent_thunder)
			return "Code Yellow"
		if(access_cent_storage)
			return "Code Orange"
		if(access_cent_living)
			return "Code Green"
		if(access_cent_medical)
			return "Code White"
		if(access_cent_teleporter)
			return "Code Blue"
		if(access_cent_specops)
			return "Code Black"
		if(access_cent_creed)
			return "Code Silver"
		if(access_cent_captain)
			return "Code Gold"

/proc/get_all_jobs()
	return list("Assistant", "Station Engineer", "Shaft Miner", "Detective", "Medical Doctor", "Captain", "Security Officer", "Warden",
				"Geneticist", "Scientist", "Head of Security", "Head of Personnel", "Atmospheric Technician",
				"Chaplain", "Bartender", "Chemist", "Janitor", "Clown", "Mime", "Chef", "Roboticist", "Quartermaster",
				"Chief Engineer", "Research Director", "Botanist", "Librarian", "Lawyer", "Virologist", "Cargo Technician", "Chief Medical Officer")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

/obj/proc/GetJobName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/jobName

	if(istype(src, /obj/item/device/pda))
		if(src:id)
			jobName = src:id:assignment
	if(istype(src, /obj/item/weapon/card/id))
		jobName = src:assignment

	if(jobName in get_all_jobs())
		return jobName
	else
		return "Unknown"
