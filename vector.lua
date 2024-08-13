Vector = {}

--- Function to create a new Vector
function Vector.new(x, y)
   return { x = x or 0, y = y or 0 }
end

--- Addition of two Vectors
function Vector.add(v1, v2)
   return Vector.new(v1.x + v2.x, v1.y + v2.y)
end

--- Subtraction of two Vectors
function Vector.sub(v1, v2)
   return Vector.new(v1.x - v2.x, v1.y - v2.y)
end

--- Scalar multiplication of a Vector
function Vector.mul(v, scalar)
   return Vector.new(v.x * scalar, v.y * scalar)
end

--- Dot product of two Vectors
function Vector.dot(v1, v2)
   return v1.x * v2.x + v1.y * v2.y
end

--- Magnitude (length) of a Vector
function Vector.mag(v)
   return math.sqrt(v.x ^ 2 + v.y ^ 2)
end

--- Normalization of a Vector (returns a unit Vector)
function Vector.normalize(v)
   local mag = Vector.mag(v)
   if mag ~= 0 then
      return Vector.mul(v, 1 / mag)
   else
      return Vector.new()
   end
end

---- Normalized Vector pointing from a to b
function Vector.normal(v1, v2)
   return Vector.normalize(Vector.sub(v2, v1))
end

--- Distance between two Vectors
function Vector.dist(v1, v2)
   return Vector.mag(Vector.sub(v2, v1))
end
