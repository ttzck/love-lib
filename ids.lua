--- A more editor-friendly method for specifying string-based IDs.
--- Use like `ID.SomeWord = ""`. The right-hand side will be replaced with `SomeWord`.
--- This allows for renaming, documentation, and autocomplete.
ID = {}

--- This is a Word
ID.SomeWord = ""

for key, _ in pairs(ID) do
   ID[key] = key
end
