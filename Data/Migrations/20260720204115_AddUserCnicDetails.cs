using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace marriage_hall_backend.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddUserCnicDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CnicDateOfBirth",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicDateOfExpiry",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicDateOfIssue",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicFatherOrHusbandName",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicFullName",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicGender",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CnicNumber",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "UserCnicDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CnicNumberEncrypted = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    CnicNumberHash = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    CnicLast4 = table.Column<string>(type: "nvarchar(4)", maxLength: 4, nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    FatherOrHusbandName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    DateOfBirth = table.Column<DateOnly>(type: "date", nullable: true),
                    DateOfIssue = table.Column<DateOnly>(type: "date", nullable: true),
                    DateOfExpiry = table.Column<DateOnly>(type: "date", nullable: true),
                    Gender = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    VerificationStatus = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserCnicDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserCnicDetails_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserCnicDetails_CnicNumberHash",
                table: "UserCnicDetails",
                column: "CnicNumberHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserCnicDetails_UserId",
                table: "UserCnicDetails",
                column: "UserId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserCnicDetails");

            migrationBuilder.AddColumn<DateOnly>(
                name: "CnicDateOfBirth",
                table: "Users",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "CnicDateOfExpiry",
                table: "Users",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "CnicDateOfIssue",
                table: "Users",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CnicFatherOrHusbandName",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CnicFullName",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CnicGender",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CnicNumber",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
