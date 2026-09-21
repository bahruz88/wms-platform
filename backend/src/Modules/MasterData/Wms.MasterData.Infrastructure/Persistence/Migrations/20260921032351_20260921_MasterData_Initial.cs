using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.MasterData.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_MasterData_Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_currency_rate",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    currency = table.Column<string>(type: "char(3)", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    rate_date = table.Column<DateOnly>(type: "date", nullable: false),
                    rate_to_base = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: false),
                    source = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_currency_rate", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_location",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    parent_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    code = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    location_type = table.Column<string>(type: "enum('CENTRAL_WAREHOUSE','SUB_LOCATION','SHELF','RESTAURANT','IN_TRANSIT','V_SUPPLIER','V_WASTE','V_SAMPLE','V_ADJUSTMENT')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    is_virtual = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    allows_food = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    allows_non_food = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_location", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_number_sequence",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_type = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    prefix = table.Column<string>(type: "varchar(12)", maxLength: 12, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    period = table.Column<string>(type: "varchar(8)", maxLength: 8, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    last_number = table.Column<uint>(type: "int unsigned", nullable: false),
                    padding = table.Column<byte>(type: "tinyint unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_number_sequence", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_product",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    sku = table.Column<string>(type: "varchar(48)", maxLength: 48, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(250)", maxLength: 250, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name_sort_key = table.Column<string>(type: "varchar(250)", maxLength: 250, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    barcode = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    category_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    brand = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    base_uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    default_supplier_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    min_stock = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    max_stock = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    reorder_point = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    vat_rate = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: false),
                    requires_batch = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    requires_expiry = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    issue_strategy = table.Column<string>(type: "enum('FEFO','FIFO')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    shelf_life_days = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    image_key = table.Column<string>(type: "varchar(300)", maxLength: 300, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_deleted = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_product", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_product_category",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    parent_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    code = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    product_type = table.Column<string>(type: "enum('FOOD','NON_FOOD')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    path = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_product_category", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_reason_code",
                columns: table => new
                {
                    id = table.Column<ushort>(type: "smallint unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    code = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    reason_group = table.Column<string>(type: "enum('WASTE','ADJUSTMENT','RETURN','SAMPLE','TRANSFER')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    requires_approval = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    requires_photo = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_reason_code", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_supplier",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    code = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(250)", maxLength: 250, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    tax_id = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    contact_person = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    phone = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    email = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    address = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    bank_details = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    currency = table.Column<string>(type: "char(3)", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    payment_terms = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    delivery_terms = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    incoterms = table.Column<string>(type: "varchar(16)", maxLength: 16, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    is_approved_food_supplier = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_deleted = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_supplier", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_uom",
                columns: table => new
                {
                    id = table.Column<ushort>(type: "smallint unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    code = table.Column<string>(type: "varchar(12)", maxLength: 12, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(60)", maxLength: 60, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    uom_class = table.Column<string>(type: "enum('MASS','VOLUME','COUNT')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    decimals = table.Column<byte>(type: "tinyint unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_uom", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_product_uom",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    factor_to_base = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: false),
                    is_purchase_default = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_issue_default = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    valid_from = table.Column<DateOnly>(type: "date", nullable: false),
                    valid_to = table.Column<DateOnly>(type: "date", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_product_uom", x => x.id);
                    table.ForeignKey(
                        name: "fk_master_product_uom_master_product_product_id",
                        column: x => x.product_id,
                        principalTable: "master_product",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "master_supplier_certificate",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    cert_type = table.Column<string>(type: "varchar(80)", maxLength: 80, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    cert_number = table.Column<string>(type: "varchar(80)", maxLength: 80, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    issued_date = table.Column<DateOnly>(type: "date", nullable: true),
                    expiry_date = table.Column<DateOnly>(type: "date", nullable: true),
                    attachment_id = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_master_supplier_certificate", x => x.id);
                    table.ForeignKey(
                        name: "fk_master_supplier_certificate_suppliers_supplier_id",
                        column: x => x.supplier_id,
                        principalTable: "master_supplier",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "uq_rate",
                table: "master_currency_rate",
                columns: new[] { "tenant_id", "currency", "rate_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_loc_parent",
                table: "master_location",
                columns: new[] { "tenant_id", "parent_id" });

            migrationBuilder.CreateIndex(
                name: "uq_loc_code",
                table: "master_location",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_seq",
                table: "master_number_sequence",
                columns: new[] { "tenant_id", "doc_type", "period" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_product_cat",
                table: "master_product",
                columns: new[] { "tenant_id", "category_id" });

            migrationBuilder.CreateIndex(
                name: "ix_product_name",
                table: "master_product",
                columns: new[] { "tenant_id", "name_sort_key" });

            migrationBuilder.CreateIndex(
                name: "uq_product_sku",
                table: "master_product",
                columns: new[] { "tenant_id", "sku" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_cat",
                table: "master_product_category",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_master_product_uom_product_id",
                table: "master_product_uom",
                column: "product_id");

            migrationBuilder.CreateIndex(
                name: "uq_puom",
                table: "master_product_uom",
                columns: new[] { "tenant_id", "product_id", "uom_id", "valid_from" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_reason",
                table: "master_reason_code",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_supplier_code",
                table: "master_supplier",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cert_exp",
                table: "master_supplier_certificate",
                columns: new[] { "tenant_id", "expiry_date" });

            migrationBuilder.CreateIndex(
                name: "ix_master_supplier_certificate_supplier_id",
                table: "master_supplier_certificate",
                column: "supplier_id");

            migrationBuilder.CreateIndex(
                name: "uq_uom",
                table: "master_uom",
                columns: new[] { "tenant_id", "code" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "master_currency_rate");

            migrationBuilder.DropTable(
                name: "master_location");

            migrationBuilder.DropTable(
                name: "master_number_sequence");

            migrationBuilder.DropTable(
                name: "master_product_category");

            migrationBuilder.DropTable(
                name: "master_product_uom");

            migrationBuilder.DropTable(
                name: "master_reason_code");

            migrationBuilder.DropTable(
                name: "master_supplier_certificate");

            migrationBuilder.DropTable(
                name: "master_uom");

            migrationBuilder.DropTable(
                name: "master_product");

            migrationBuilder.DropTable(
                name: "master_supplier");
        }
    }
}
