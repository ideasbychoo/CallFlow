// Shared sentinel used wherever a filter needs to represent "this
// organisation has no value for this field" (e.g. no Segment assigned, no
// Country assigned) alongside real option values. Used by Call List's
// Segment/Country filters and by the Research page's links into them, so
// organisations missing a Segment/Country aren't silently excluded from
// either place.
export const NO_VALUE = "__none__";
