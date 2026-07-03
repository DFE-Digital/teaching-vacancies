# Legacy .doc files are OLE Compound Files. Marcel (used by ActiveStorage to
# identify uploaded file content types) correctly detects the generic OLE
# container signature, but doesn't always resolve the more specific
# "application/msword" magic pattern for every .doc file layout - so it
# falls back to the generic "application/x-ole-storage" type, regardless of
# what the browser declared. That generic type then fails our content_type
# validations, which only authorize the specific document types.
#
# Registering "application/msword" as a child of "application/x-ole-storage"
# lets Marcel resolve the ambiguity using the filename extension instead:
# when a file's magic bytes match the generic OLE signature and its name
# ends in .doc, Marcel now prefers the more specific "application/msword"
# type. Other OLE-based formats (.xls, .ppt, etc.) are unaffected, since
# they aren't registered as children of the generic OLE type here.
Marcel::MimeType.extend("application/msword", parents: ["application/x-ole-storage"])
