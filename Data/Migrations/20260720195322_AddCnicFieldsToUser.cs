using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace marriage_hall_backend.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddCnicFieldsToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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
        }
    }
}
