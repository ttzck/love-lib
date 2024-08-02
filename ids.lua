--- A more editor-friendly method for specifying string-based IDs.
--- Use like `ID.SomeWord = ""`. The right-hand side will be replaced with `SomeWord`.
--- This allows for renaming, documentation, and autocomplete.
Id = {}

--- This is a Word
Id.SomeWord = ""

for key, _ in pairs(Id) do
   Id[key] = key
end
