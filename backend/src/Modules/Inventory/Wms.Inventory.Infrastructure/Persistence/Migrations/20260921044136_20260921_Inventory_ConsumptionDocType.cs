using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Inventory.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Inventory_ConsumptionDocType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "doc_type",
                table: "inv_movement_group",
                type: "enum('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST','WASTE','SAMPLE','RETURN','OPENING','REVERSAL','CONSUMPTION')",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "enum('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST','WASTE','SAMPLE','RETURN','OPENING','REVERSAL')")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "doc_type",
                table: "inv_movement_group",
                type: "enum('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST','WASTE','SAMPLE','RETURN','OPENING','REVERSAL')",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "enum('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST','WASTE','SAMPLE','RETURN','OPENING','REVERSAL','CONSUMPTION')")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }
    }
}
