Vector = {}

---@alias vector { x : number, y : number }

--- Function to create a new Vector
---@param x number?
---@param y number?
---@return vector
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

--- squared Magnitude (length) of a Vector
function Vector.sqr_mag(v)
   return v.x * v.x + v.y * v.y
end

--- Magnitude (length) of a Vector
function Vector.mag(v)
   return math.sqrt(v.x * v.x + v.y * v.y)
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

--- Clamp Vectors magnitude to max_mag
function Vector.clamp(v, max_mag)
   if Vector.mag(v) > max_mag then
      return Vector.mul(Vector.normalize(v), max_mag)
   end
   return v
end

---Returns the vector between the tip of v1 to the tip of v2
---@param v1 vector
---@param v2 vector
---@return vector
function Vector.between(v1, v2)
   return Vector.sub(v2, v1)
end

---Returns a unit vector pointing from the tip of v1 to the tip of v2
---@param v1 vector
---@param v2 vector
---@return vector
function Vector.normal(v1, v2)
   return Vector.normalize(Vector.sub(v2, v1))
end

--- squared distance between two Vectors
function Vector.sqr_dist(v1, v2)
   return Vector.sqr_mag(Vector.sub(v2, v1))
end

--- Distance between two Vectors
function Vector.dist(v1, v2)
   return Vector.mag(Vector.sub(v2, v1))
end

--- Rotate vector phi radians
function Vector.rot(v, phi)
   local sin = math.sin(phi)
   local cos = math.cos(phi)
   local x = v.x * cos - v.y * sin
   local y = v.x * sin + v.y * cos
   return Vector.new(x, y)
end
