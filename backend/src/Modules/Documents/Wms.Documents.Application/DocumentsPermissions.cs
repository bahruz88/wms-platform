namespace Wms.Documents.Application;

public static class DocumentsPermissions
{
    public const string AttachmentView = "doc.attachment.view";
    public const string AttachmentUpload = "doc.attachment.upload";
    public const string AttachmentDelete = "doc.attachment.delete";

    /// <summary>Lets a user delete somebody else's attachment (contract: "yalnız yükləyən və ya doc.attachment.manage").</summary>
    public const string AttachmentManage = "doc.attachment.manage";
}
