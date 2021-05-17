# Add Office 2007+ file types to MimeMagic
#   MimeMagic used to come with these built in, but they have been removed as some newer versions
#   of mime type databases come with these. The one on Alpine (which we use in production) does
#   not, and neither do many other packages of `shared-mime-info` (including Homebrew on Mac).
[
  ["application/vnd.openxmlformats-officedocument.presentationml.presentation", [[0, "PK\003\004", [[0..5000, "[Content_Types].xml", [[0..5000, "ppt/"]]]]]]],
  ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", [[0, "PK\003\004", [[0..5000, "[Content_Types].xml", [[0..5000, "xl/"]]]]]]],
  ["application/vnd.openxmlformats-officedocument.wordprocessingml.document", [[0, "PK\003\004", [[0..5000, "[Content_Types].xml", [[0..5000, "word/"]]]]]]],
].each do |magic|
  MimeMagic.add(magic[0], magic: magic[1])
end
