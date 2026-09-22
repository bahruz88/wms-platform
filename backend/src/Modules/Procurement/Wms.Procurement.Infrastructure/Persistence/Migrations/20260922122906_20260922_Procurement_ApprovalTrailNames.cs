using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Procurement.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260922_Procurement_ApprovalTrailNames : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "approver_username",
                table: "proc_approval_step",
                type: "varchar(64)",
                maxLength: 64,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "delegated_from_username",
                table: "proc_approval_step",
                type: "varchar(64)",
                maxLength: 64,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "requested_by_username",
                table: "proc_approval_instance",
                type: "varchar(64)",
                maxLength: 64,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "approver_username",
                table: "proc_approval_step");

            migrationBuilder.DropColumn(
                name: "delegated_from_username",
                table: "proc_approval_step");

            migrationBuilder.DropColumn(
                name: "requested_by_username",
                table: "proc_approval_instance");
        }
    }
}
