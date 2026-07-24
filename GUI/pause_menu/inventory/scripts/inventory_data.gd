class_name	InventoryData extends Resource

signal equipment_changed
signal ability_acquired( ability : AbilityItemData)

@export var slots : Array[SlotData]
var equipment_slot_count : int = 4

func _init() -> void:
	connect_slots()
	pass

func inventory_slots() -> Array[SlotData]:
	return slots.slice(0, -equipment_slot_count)
	
func equipment_slots() -> Array[SlotData]:
	return slots.slice(-equipment_slot_count,slots.size())	

func add_item( item : ItemData, count : int = 1) -> bool:
	if item is AbilityItemData:
		ability_acquired.emit( item)
		SaveManager.save_items()
		return true
	
	if item is EquipableItemData:		
		var equipable_item: EquipableItemData = item as EquipableItemData
		# Check if it's a weapon type
		if equipable_item.type == EquipableItemData.Type.WEAPON:
			SaveManager.save_items()
			return auto_equip_weapon(equipable_item)
		
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				SaveManager.save_items()
				return true
				
	for i in inventory_slots().size():
		if slots[i] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			new.changed.connect(slot_changed)
			SaveManager.save_items()
			return true
					
	print ("inv was full!")
	
	return false

#func remove_item(item : ItemData, count : int = 1) -> void:
	#for s in slots:
		#if s:
			#if s.item_data == item:
				#s.quantity -= count
				#if s.quantity == 0:
					#
				#return
	
func connect_slots() -> void:
	for s in slots:
		if s:
			s.changed.connect( slot_changed)
			
func slot_changed() -> void:
	for s in slots:
		if s:
			if s.quantity < 1:
				s.changed.disconnect( slot_changed)
				var index = slots.find( s )
				slots[index] = null
				emit_changed()
	pass
	
func get_save_data() -> Array:
	var item_save: Array = []
	for i in slots.size():
		item_save.append(item_to_save( slots[i]))	
	return item_save
	
func item_to_save(slot : SlotData) -> Dictionary:
	var result = { item = "", quantity = 0 }
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data != null:
			result.item = slot.item_data.resource_path
	return result	
						
func parse_save_data( save_data : Array) -> void:
	var array_size = slots.size()
	slots.clear()
	slots.resize( array_size)
	for i in save_data.size():
		slots[i] = item_from_save(save_data[i])
	connect_slots()
	
func item_from_save( save_object : Dictionary) -> SlotData:
	if save_object.item == "":
		return null
	var new_slot : SlotData = SlotData.new()
	new_slot.item_data = load( save_object.item)
	new_slot.quantity = int( save_object.quantity)	
	return new_slot
	
func use_item( item : ItemData, count : int = 1) -> bool:
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	return false				

func swap_items_by_index( i1 : int, i2 : int) -> void:
	var temp : SlotData = slots[i1]
	slots[i1] = slots[i2]
	slots[i2] = temp
	pass

func equip_item( slot: SlotData) -> void:
	if slot == null or not slot.item_data is EquipableItemData:
		return
	var item: EquipableItemData = slot.item_data
	var slot_index : int = slots.find(slot) 	
	var equipment_index : int = slots.size() - equipment_slot_count
	
	match item.type:
		EquipableItemData.Type.ARMOR:
			equipment_index += 0
			pass
		EquipableItemData.Type.WEAPON:
			equipment_index += 1
			pass
		EquipableItemData.Type.AMULET:
			equipment_index += 2
			pass
		EquipableItemData.Type.RING:
			equipment_index += 3
			pass			
	
	var unequiped_slot : SlotData = slots[equipment_index]
	
	slots[slot_index] = unequiped_slot
	slots[equipment_index] = slot
	
	equipment_changed.emit()
	PauseMenu.focused_item_changed(unequiped_slot)	
	pass

func get_attack_bonus() -> int:
	return get_equipment_bonus(EquipableItemModifier.Type.ATTACK)

func get_attack_bonus_diff(item : EquipableItemData) -> int:
	var before : int = get_attack_bonus()
	var after : int= get_equipment_bonus(EquipableItemModifier.Type.ATTACK, item)
	return after - before
	
func get_defense_bonus() -> int:
	return get_equipment_bonus(EquipableItemModifier.Type.DEFENSE)					

func get_defense_bonus_diff(item : EquipableItemData) -> int:
	var before : int = get_defense_bonus()
	var after : int= get_equipment_bonus(EquipableItemModifier.Type.DEFENSE, item)
	return after - before
		
func get_equipment_bonus( bonus_type: EquipableItemModifier.Type, compare: EquipableItemData = null) -> int:
	var bonus : int = 0
	for s in equipment_slots():
		if s == null:
			continue
		var e : EquipableItemData = s.item_data
		if compare:
			if e.type == compare.type:
				e = compare
		for m in e.modifiers:
			if m.type == bonus_type:
				bonus += m.value
	return bonus
			
func get_item_held_quantity(_item : ItemData) -> int:
	for slot in slots:
		if slot:
			if slot.item_data:
				if slot.item_data == _item:
					return slot.quantity
	return 0
			
func check_if_equiped( name: String = "") -> bool:
	for s in equipment_slots():
		if s == null:
			continue
		var e : EquipableItemData = s.item_data
		if name:
			if e.name == name:
				return true
	return false

func auto_equip_weapon(weapon: EquipableItemData) -> bool:
	# Calculate weapon equipment slot index
	var weapon_slot_index: int = slots.size() - equipment_slot_count + 1  # +1 for weapon slot
	# Get currently equipped weapon (if any)
	var current_weapon: SlotData = slots[weapon_slot_index]
	# Create new slot for the picked up weapon
	var new_weapon_slot = SlotData.new()
	new_weapon_slot.item_data = weapon
	new_weapon_slot.quantity = 1
	new_weapon_slot.changed.connect(slot_changed)
	# Equip the new weapon
	slots[weapon_slot_index] = new_weapon_slot
	# If there was a weapon equipped, move it to inventory
	if current_weapon != null:
		# Try to add old weapon to inventory
		var added_to_inventory = _add_to_inventory(current_weapon)
		if not added_to_inventory:
			print("Warning: Old weapon couldn't fit in inventory!")
			# You could drop it on the ground here if you want
	# Emit equipment changed signal
	equipment_changed.emit()
	return true
	
func _add_to_inventory(slot: SlotData) -> bool:
	# Try to find empty inventory slot
	for i in inventory_slots().size():
		if slots[i] == null:
			slots[i] = slot
			return true
	# Inventory is full
	return false	
