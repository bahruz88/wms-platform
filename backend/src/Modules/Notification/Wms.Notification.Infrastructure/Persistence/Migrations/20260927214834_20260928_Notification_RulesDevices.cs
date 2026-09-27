using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Notification.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260928_Notification_RulesDevices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ---------------------------------------------------------------- notif_rule
            //
            // The table is dropped and rebuilt rather than altered column by column.
            //
            // Two reasons. It is empty by construction: until this migration the module had no way to
            // write a rule — no create endpoint, no seed — so there is nothing to preserve. And the
            // alteration cannot be expressed safely: an earlier attempt failed partway through
            // (MySQL rejects '' as an ENUM default, which is what EF scaffolded for `digest`), leaving
            // some databases with the index and `channel` already dropped. `DROP TABLE IF EXISTS`
            // reaches the same shape from either state, which a sequence of ALTERs cannot.
            //
            // The shape follows the contract — channels and target users are lists — and the table
            // gains the audit and row_version columns of spec §6.2.
            migrationBuilder.Sql("DROP TABLE IF EXISTS `notif_rule`;");
            migrationBuilder.Sql("""
                CREATE TABLE `notif_rule` (
                    `id` int unsigned NOT NULL AUTO_INCREMENT,
                    `tenant_id` int unsigned NOT NULL,
                    `event_type` varchar(120) CHARACTER SET utf8mb4 NOT NULL,
                    `severity` enum('INFO','WARNING','CRITICAL') CHARACTER SET utf8mb4 NOT NULL,
                    `channels` varchar(48) CHARACTER SET utf8mb4 NOT NULL,
                    `target_role_code` varchar(48) CHARACTER SET utf8mb4 NULL,
                    `target_user_ids` varchar(500) CHARACTER SET utf8mb4 NULL,
                    `target_location_scoped` tinyint(1) NOT NULL,
                    `digest` enum('IMMEDIATE','DAILY') CHARACTER SET utf8mb4 NOT NULL,
                    `is_system` tinyint(1) NOT NULL,
                    `is_active` tinyint(1) NOT NULL,
                    `created_at` datetime(3) NOT NULL,
                    `created_by` int unsigned NOT NULL,
                    `updated_at` datetime(3) NULL,
                    `updated_by` int unsigned NULL,
                    `row_version` int unsigned NOT NULL,
                    CONSTRAINT `pk_notif_rule` PRIMARY KEY (`id`)
                ) CHARACTER SET=utf8mb4;
                """);

            migrationBuilder.AddColumn<long>(
                name: "entity_id",
                table: "notif_message",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "entity_type",
                table: "notif_message",
                type: "varchar(60)",
                maxLength: 60,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "link",
                table: "notif_message",
                type: "varchar(300)",
                maxLength: 300,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<uint>(
                name: "location_id",
                table: "notif_message",
                type: "int unsigned",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "notif_device",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    user_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    device_id = table.Column<string>(type: "varchar(128)", maxLength: 128, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    platform = table.Column<string>(type: "enum('ANDROID','IOS')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    push_token = table.Column<string>(type: "varchar(512)", maxLength: 512, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    app_version = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    registered_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_notif_device", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "uq_notif_rule",
                table: "notif_rule",
                columns: new[] { "tenant_id", "event_type", "target_role_code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_notif_device",
                table: "notif_device",
                columns: new[] { "tenant_id", "user_id", "device_id" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "notif_device");

            // Up rebuilt the table, so the rollback rebuilds it too — reversing column by column
            // would leave `channels` behind and no `channel`/`recipient_role` to put back.
            migrationBuilder.Sql("DROP TABLE IF EXISTS `notif_rule`;");
            migrationBuilder.Sql("""
                CREATE TABLE `notif_rule` (
                    `id` int unsigned NOT NULL AUTO_INCREMENT,
                    `tenant_id` int unsigned NOT NULL,
                    `event_type` varchar(120) CHARACTER SET utf8mb4 NOT NULL,
                    `recipient_role` varchar(48) CHARACTER SET utf8mb4 NOT NULL,
                    `channel` varchar(16) CHARACTER SET utf8mb4 NOT NULL,
                    `severity` enum('INFO','WARNING','CRITICAL') CHARACTER SET utf8mb4 NOT NULL,
                    `is_active` tinyint(1) NOT NULL,
                    CONSTRAINT `pk_notif_rule` PRIMARY KEY (`id`)
                ) CHARACTER SET=utf8mb4;
                """);
            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX `uq_notif_rule` ON `notif_rule` (`tenant_id`, `event_type`, `recipient_role`, `channel`);");


            migrationBuilder.DropColumn(
                name: "entity_id",
                table: "notif_message");

            migrationBuilder.DropColumn(
                name: "entity_type",
                table: "notif_message");

            migrationBuilder.DropColumn(
                name: "link",
                table: "notif_message");

            migrationBuilder.DropColumn(
                name: "location_id",
                table: "notif_message");

        }

    }
}
