using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Documents.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260922_Documents_AttachmentUpload : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "scan_result",
                table: "common_attachment",
                type: "varchar(200)",
                maxLength: 200,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            // Hand-edited: EF scaffolds defaultValue "" for a NOT NULL enum, which MySQL rejects in strict
            // mode ("Invalid default value for 'status'"). Rows written before the presigned upload flow
            // existed are complete by definition, so they backfill as READY; the domain always writes the
            // value explicitly, the DDL default only backstops tooling that bypasses the factories (§8.5).
            migrationBuilder.AddColumn<string>(
                name: "status",
                table: "common_attachment",
                type: "enum('PENDING','SCANNING','READY','REJECTED')",
                nullable: false,
                defaultValue: "READY")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_att_status",
                table: "common_attachment",
                columns: new[] { "tenant_id", "status", "uploaded_at" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "ix_att_status",
                table: "common_attachment");

            migrationBuilder.DropColumn(
                name: "scan_result",
                table: "common_attachment");

            migrationBuilder.DropColumn(
                name: "status",
                table: "common_attachment");
        }
    }
}
