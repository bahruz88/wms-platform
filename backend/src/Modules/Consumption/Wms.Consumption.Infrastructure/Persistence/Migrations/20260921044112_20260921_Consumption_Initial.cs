using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Consumption.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Consumption_Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_menu_item",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    code = table.Column<string>(type: "varchar(48)", maxLength: 48, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    pos_code = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(250)", maxLength: 250, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name_sort_key = table.Column<string>(type: "varchar(250)", maxLength: 250, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    category = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    is_sub_recipe = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: true),
                    is_deleted = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_menu_item", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_recipe",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    menu_item_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    version_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    yield_portions = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 1.0000m),
                    status = table.Column<string>(type: "enum('DRAFT','ACTIVE','ARCHIVED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    valid_from = table.Column<DateOnly>(type: "date", nullable: false),
                    valid_to = table.Column<DateOnly>(type: "date", nullable: true),
                    note = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_recipe", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_run",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    business_date = table.Column<DateOnly>(type: "date", nullable: false),
                    import_id = table.Column<long>(type: "bigint", nullable: false),
                    status = table.Column<string>(type: "enum('DRAFT','CALCULATED','POSTED','FAILED','REVERSED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    movement_group_id = table.Column<long>(type: "bigint", nullable: true),
                    shortfall_count = table.Column<ushort>(type: "smallint unsigned", nullable: false, defaultValue: (ushort)0),
                    unmapped_count = table.Column<ushort>(type: "smallint unsigned", nullable: false, defaultValue: (ushort)0),
                    failure_reason = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    calculated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    posted_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    posted_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_run", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_sales_import",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    business_date = table.Column<DateOnly>(type: "date", nullable: false),
                    source = table.Column<string>(type: "enum('POS','CSV','MANUAL')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    external_ref = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    status = table.Column<string>(type: "enum('DRAFT','SUBMITTED','CONSUMED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    line_count = table.Column<ushort>(type: "smallint unsigned", nullable: false, defaultValue: (ushort)0),
                    gross_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    imported_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    imported_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_sales_import", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_recipe_line",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    recipe_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    component_type = table.Column<string>(type: "enum('FOOD_PRODUCT','SUB_RECIPE')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    sub_menu_item_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    qty_per_portion = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    yield_pct = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: false, defaultValue: 100.0000m),
                    is_optional = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    attach_rate_pct = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: false, defaultValue: 100.0000m),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_recipe_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_cons_recipe_line_cons_recipe_recipe_id",
                        column: x => x.recipe_id,
                        principalTable: "cons_recipe",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_run_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    run_id = table.Column<long>(type: "bigint", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    theoretical_qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    posted_qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    shortfall_qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    base_uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_run_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_cons_run_line_cons_run_run_id",
                        column: x => x.run_id,
                        principalTable: "cons_run",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cons_sales_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    import_id = table.Column<long>(type: "bigint", nullable: false),
                    menu_item_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    raw_pos_code = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    qty_sold = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    gross_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cons_sales_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_cons_sales_line_cons_sales_import_import_id",
                        column: x => x.import_id,
                        principalTable: "cons_sales_import",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_menu_name",
                table: "cons_menu_item",
                columns: new[] { "tenant_id", "name_sort_key" });

            migrationBuilder.CreateIndex(
                name: "uq_menu_code",
                table: "cons_menu_item",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_menu_pos",
                table: "cons_menu_item",
                columns: new[] { "tenant_id", "pos_code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_recipe_eff",
                table: "cons_recipe",
                columns: new[] { "tenant_id", "menu_item_id", "valid_from", "valid_to" });

            migrationBuilder.CreateIndex(
                name: "uq_recipe_ver",
                table: "cons_recipe",
                columns: new[] { "tenant_id", "menu_item_id", "version_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cons_recipe_line_recipe_id",
                table: "cons_recipe_line",
                column: "recipe_id");

            migrationBuilder.CreateIndex(
                name: "uq_rline",
                table: "cons_recipe_line",
                columns: new[] { "tenant_id", "recipe_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_run_status",
                table: "cons_run",
                columns: new[] { "tenant_id", "status", "business_date" });

            migrationBuilder.CreateIndex(
                name: "uq_run_day",
                table: "cons_run",
                columns: new[] { "tenant_id", "location_id", "business_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_run_doc",
                table: "cons_run",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cons_run_line_run_id",
                table: "cons_run_line",
                column: "run_id");

            migrationBuilder.CreateIndex(
                name: "uq_rl",
                table: "cons_run_line",
                columns: new[] { "tenant_id", "run_id", "product_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_sales_status",
                table: "cons_sales_import",
                columns: new[] { "tenant_id", "status", "business_date" });

            migrationBuilder.CreateIndex(
                name: "uq_sales_day",
                table: "cons_sales_import",
                columns: new[] { "tenant_id", "location_id", "business_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cons_sales_line_import_id",
                table: "cons_sales_line",
                column: "import_id");

            migrationBuilder.CreateIndex(
                name: "uq_sline",
                table: "cons_sales_line",
                columns: new[] { "tenant_id", "import_id", "menu_item_id", "raw_pos_code" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "cons_menu_item");

            migrationBuilder.DropTable(
                name: "cons_recipe_line");

            migrationBuilder.DropTable(
                name: "cons_run_line");

            migrationBuilder.DropTable(
                name: "cons_sales_line");

            migrationBuilder.DropTable(
                name: "cons_recipe");

            migrationBuilder.DropTable(
                name: "cons_run");

            migrationBuilder.DropTable(
                name: "cons_sales_import");
        }
    }
}
