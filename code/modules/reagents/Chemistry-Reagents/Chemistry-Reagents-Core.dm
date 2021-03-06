/datum/reagent/blood
	data = new/list("donor" = null, "viruses" = null, "species" = "Human", "blood_DNA" = null, "blood_type" = null, "blood_colour" = "#A10808", "resistances" = null, "trace_chem" = null, "antibodies" = list())
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	metabolism = REM * 5
	color = "#C80000"
	taste_description = "iron"
	taste_mult = 1.3

/datum/reagent/blood/initialize_data(var/newdata)
	..()
	if (data && data["blood_colour"])
		color = data["blood_colour"]
	return

/datum/reagent/blood/get_data() // Just in case you have a reagent that handles data differently.
	var/t = data.Copy()
	if (t["virus2"])
		var/list/v = t["virus2"]
		t["virus2"] = v.Copy()
	return t

/datum/reagent/blood/touch_turf(var/turf/T)
	if (!istype(T) || volume < 3)
		return
	if (!data["donor"] || istype(data["donor"], /mob/living/carbon/human))
		blood_splatter(T, src, TRUE)

/datum/reagent/blood/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)

	var/effective_dose = dose
	if (issmall(M)) effective_dose *= 2

	if (effective_dose > 5)
		M.adjustToxLoss(removed)
	if (effective_dose > 15)
		M.adjustToxLoss(removed)

/*	if (data && data["virus2"])
		var/list/vlist = data["virus2"]
		if (vlist.len)
			for (var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if (V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())*/

/datum/reagent/blood/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	return
/*	if (data && data["virus2"])
		var/list/vlist = data["virus2"]
		if (vlist.len)
			for (var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if (V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())
	if (data && data["antibodies"])
		M.antibodies |= data["antibodies"]*/

/datum/reagent/blood/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.inject_blood(src, volume)
	remove_self(volume)

// pure concentrated antibodies
/datum/reagent/antibodies
	data = list("antibodies"=list())
	name = "Antibodies"
	taste_description = "slime"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"

/datum/reagent/antibodies/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if (data)
		M.antibodies |= data["antibodies"]
	..()

#define WATER_LATENT_HEAT 19000 // How much heat is removed when applied to a hot turf, in J/unit (19000 makes 120 u of water roughly equivalent to 4L)
/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C877"
	metabolism = REM * 10
	taste_description = "water"

/datum/reagent/water/touch_turf(var/turf/T)
	if (!istype(T))
		return

	var/datum/gas_mixture/environment = T.return_air()
	var/min_temperature = T0C + 100 // 100C, the boiling point of water

	if (environment && environment.temperature > min_temperature) // Abstracted as steam or something
		var/removed_heat = between(0, volume * WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
		environment.add_thermal_energy(-removed_heat)
		if (prob(5))
			T.visible_message("<span class='warning'>The water sizzles as it lands on \the [T]!</span>")

	else if (volume >= 10)
		T.wet_floor(1)

/datum/reagent/water/touch_obj(var/obj/O)
/*
	if (istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if (!cube.wrapped)
			cube.Expand()*/

/datum/reagent/water/touch_mob(var/mob/living/L, var/amount)
	if (istype(L))
		var/needed = L.fire_stacks * 10
		if (amount > needed)
			L.fire_stacks = FALSE
			L.ExtinguishMob()
			remove_self(needed)
		else
			L.adjust_fire_stacks(-(amount / 10))
			remove_self(amount)

/datum/reagent/water/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if (M.water < 0)
		M.water += rand(40,50)
	M.water += removed * 15