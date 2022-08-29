const SEC_IN_USEC : int = 1000000

static func map_callv(i_es : Array, f : String, vargs : Array) -> Array:
	var o_es : Array = []
	for e in i_es: o_es.append(e.callv(f,vargs))
	return o_es

# Precondition: 
# * !arr.empty()
static func centroid(es : Array):
	var sum = es[0]
	for i in range(1,es.size()):
		sum += es[i]
	return sum / es.size()

static func now() -> float:
	return float(Time.get_ticks_usec())/SEC_IN_USEC
