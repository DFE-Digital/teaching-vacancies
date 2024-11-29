if @vacancy.persisted?
  json.id @vacancy.id
else
  json.errors @vacancy.errors
end
