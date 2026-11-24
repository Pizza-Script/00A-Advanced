class_name MyRect2

# Godot Projects\B Systems\B05 Grids\10 MyRect2i
# Rect2i not a class, cannot be extended
# 035 Dungeon Generation

# MyRect = MyRect.new(L, T, R, B)
# MyRect = MyRect.new_rect(Rect2)
# MyRect = MyRect.new_pos(pos, size)
# MyRect = MyRect.new_xy(x, y, width, height)

# MyRect.rect
# MyRect.position
# MyRect.size
# MyRect.end
# MyRect.width
# MyRect.height
# MyRect.area

# MyRect.L
# MyRect.T
# MyRect.R
# MyRect.B
# MyRect.TL
# MyRect.TR
# MyRect.BL
# MyRect.BR

# MyRect.intersection(other_rect)
# MyRect.intersects(other_rect)
# MyRect.has_point(v2_point)

# MyRect.center()
# MyRect.is_overlaps_rect(other_rect)
# MyRect.is_overlaps_line(v2_start, v2_stop)
# MyRect.intersect_line(v2_start, v2_stop)
# MyRect.intersect_ray(v2_origin, v2_direction)
# MyRect.edge_intersect_line(Edge.LTRB, v2_start, v2_stop)
# MyRect.edge_intersects_ray(Edge.LTRB, v2_origin, v2_direction)
# MyRect.closest_point(point)

enum Edge {
	L,
	T,
	R,
	B
}

var rect: Rect2

var position: Vector2:
	set(val): rect.position = val
	get: return rect.position

var size: Vector2:
	set(val): rect.size = val
	get: return rect.size

var end: Vector2:
	set(val): rect.end = val
	get: return rect.end

var width: float:
	set(val): rect.size.x = val
	get: return rect.size.x

var height: float:
	set(val): rect.size.y = val
	get: return rect.size.y

var area: float:
	get: return rect.get_area()

var L: float:
	set(val):
		rect.size.x = rect.end.x - val											# change size
		rect.position.x = val													# before moving
	get: return rect.position.x

var T: float:
	set(val):
		rect.size.y = rect.end.y - val
		rect.position.y = val
	get: return rect.position.y

var R: float:
	set(val): rect.end.x = val
	get: return rect.end.x

var B: float:
	set(val): rect.end.y = val
	get: return rect.end.y

var LT: Vector2:
	set(val):
		rect.size += rect.position - val
		rect.position = val
	get: return rect.position

var RT: Vector2:
	set(val):
		rect.size.x += val.x - rect.end.x										# move right
		rect.size.y += rect.position.y - val.y									# move top
		rect.position.y = val.y													# move top
	get: return rect.position + Vector2(rect.size.x, 0)

var LB: Vector2:
	set(val):
		rect.size.x += rect.position.x - val.x									# move left
		rect.size.y += val.y - rect.end.y										# move bottom
		rect.position.x = val.x													# move left
	get: return rect.position + Vector2(0, rect.size.y)

var RB: Vector2:
	set(val): rect.end = val													# end also changes size
	get: return rect.end


func _init(_left: float, _top: float, _right: float, _bottom: float) -> void:
	rect = Rect2()
	L = _left
	T = _top
	R = _right
	B = _bottom


static func new_rect(_rect: Rect2) -> MyRect2:
	return MyRect2.new(_rect.position.x, _rect.position.y, _rect.end.x, _rect.end.y)


static func new_pos(_position: Vector2i, _size: Vector2i) -> MyRect2:
	return MyRect2.new(_position.x, _position.y, _position.x + _size.x, _position.y + _size.y)


static func new_xy(x: float, y: float, _width: float, _height: float) -> MyRect2:
	return MyRect2.new(x, y, x + _width, y + _height)


# BUILT-IN METHODS
func intersection(other: MyRect2) -> MyRect2:									# negative size if not overlapping
	var result: MyRect2 = MyRect2.new(0, 0, 0, 0)
	result.L = maxf(L, other.L)
	result.R = minf(R, other.R)
	result.T = maxf(T, other.T)
	result.B = minf(B, other.B)
	return result


func intersects(other: MyRect2, include_borders: bool = false) -> bool:
	return rect.intersects(other.rect, include_borders)


func has_point(point: Vector2) -> bool:											# NOTE: convention, BR not included
	return rect.has_point(point)


# CUSTOM METHODS
func center() -> Vector2:
	var _center: Vector2

	var ends_in_one_x: float = int(R - L) & 1									# AND - both
	var ends_in_one_y: float = int(B - T) & 1

	var ternary_x: int = (randi() % 2) if ends_in_one_x == 1 else 0				# "true" if check() else "false"
	var ternary_y: int = (randi() % 2) if ends_in_one_y == 1 else 0

	_center.x = float((L + R) / 2) + ternary_x									# center + random (or 0)
	_center.y = float((T + B) / 2) + ternary_y

	return _center


func is_overlaps_rect(other: MyRect2) -> bool:
	if L > other.R || R < other.L\
	|| T > other.B || B < other.T:												# inverted y
		return false

	return true


func is_overlaps_line(line_start: Vector2, line_stop: Vector2) -> bool:
	var other_LT: Vector2
	var other_RB: Vector2

	if line_start.x < line_stop.x:												# other rect from line
		other_LT.x = line_start.x
		other_RB.x = line_stop.x
	elif line_start.x > line_stop.x:
		other_LT.x = line_stop.x
		other_RB.x = line_start.x

	if line_start.y < line_stop.y:
		other_LT.y = line_start.y
		other_RB.y = line_stop.y
	elif line_start.y > line_stop.y:
		other_LT.y = line_stop.y
		other_RB.y = line_start.y

	if L > other_RB.x || R < other_LT.x\
	|| T > other_RB.y || B < other_LT.y:										# inverted y
		return false															# rect_overlaps_rect

	return true


func intersect_line(line_start: Vector2, line_stop: Vector2) -> Vector2:		# INF if not intersecting
	var intersect: Vector2

	intersect = edge_intersect_line(Edge.L, line_start, line_stop)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersect_line(Edge.T, line_start, line_stop)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersect_line(Edge.R, line_start, line_stop)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersect_line(Edge.B, line_start, line_stop)
	if intersect.is_finite() == true:
		return intersect

	return Vector2.INF


func intersect_ray(origin: Vector2, direction: Vector2) -> Vector2:				# INF if not intersecting
	var intersect: Vector2														# TODO: UNCHECKED

	intersect = edge_intersects_ray(Edge.L, origin, direction)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersects_ray(Edge.T, origin, direction)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersects_ray(Edge.R, origin, direction)
	if intersect.is_finite() == true:
		return intersect

	intersect = edge_intersects_ray(Edge.B, origin, direction)
	if intersect.is_finite() == true:
		return intersect

	return Vector2.INF


func edge_intersect_line(edge: Edge, line_start: Vector2, line_stop: Vector2) -> Vector2:
	var edge_start: Vector2														# c
	var edge_stop: Vector2														# d

	if edge == Edge.L:
		edge_start = LB
		edge_stop = LT

	if edge == Edge.T:
		edge_start = LT
		edge_stop = RT

	if edge == Edge.R:
		edge_start = RT
		edge_stop = RB

	if edge == Edge.B:
		edge_start = RB
		edge_stop = LB

	var vector_ab: Vector2 = line_stop - line_start
	var vector_cd: Vector2 = edge_stop - edge_start
	var cross_ab_cd: float = vector_ab.cross(vector_cd)

	if (cross_ab_cd == 0): return Vector2.INF									# parallel or colinear

	var vector_ca: Vector2 = line_start - edge_start
	var cross_ab_ca: float = vector_ab.cross(vector_ca)
	var cross_cd_ca: float = vector_cd.cross(vector_ca)

	var lerp_ab: float = cross_ab_ca / cross_ab_cd
	var lerp_cd: float = cross_cd_ca / cross_ab_cd

	if lerp_ab >= 0.0 && lerp_ab <= 1.0\
	&& lerp_cd >= 0.0 && lerp_cd <= 1.0:
		return line_start + vector_ab * lerp_cd

	return Vector2.INF


func edge_intersects_ray(edge: Edge, origin: Vector2, direction: Vector2) -> Vector2:
	var edge_start: Vector2														# c
	var edge_stop: Vector2														# d

	if edge == Edge.L:
		edge_start = LB
		edge_stop = LT

	if edge == Edge.T:
		edge_start = LT
		edge_stop = RT

	if edge == Edge.R:
		edge_start = RT
		edge_stop = RB

	if edge == Edge.B:
		edge_start = RB
		edge_stop = LB

	var edge_vector: Vector2 = edge_stop - edge_start
	var origin_diff: Vector2 = edge_start - origin
	var cross_dir: float = direction.cross(edge_vector)

	if (cross_dir == 0): return Vector2.INF										# parallel

	var cross_AB_A: float = origin_diff.cross(direction)
	var cross_AB_B: float = origin_diff.cross(edge_vector)						# if 0 = co-linear

	var lerp_A: float = cross_AB_A / cross_dir
	var lerp_B: float = cross_AB_B / cross_dir

	if lerp_B >= 0 && lerp_A >= 0 && lerp_A <= 1:								# both positive
		return origin + direction * lerp_B										# intersecting
	else:
		return Vector2.INF														# 1 ray behind origin


func closest_point(point: Vector2) -> Vector2:
	if has_point(point) == false:												# outside only (if inside = mouse pos)
		return point.clamp(LT, RB)

	else:																		# inside only (if outside = corner)
		var start: Vector2 = point - position
		var stop: Vector2 = end - point

		var minimum: Vector2 = start.min(stop)
		var smallest: float = minf(minimum.x, minimum.y)
		var closest: Vector2

		if smallest == start.x:
			closest = Vector2(L, point.y)
		elif smallest == stop.x:
			closest = Vector2(R, point.y)
		elif smallest == start.y:
			closest = Vector2(point.x, T)
		elif smallest == stop.y:
			closest = Vector2(point.x, B)

		return closest
