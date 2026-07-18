using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace marriage_hall_backend.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddIsActiveToFoodPackageAndExtraService : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "FoodPackages",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "ExtraServices",
                type: "bit",
                nullable: false,
                defaultValue: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "FoodPackages");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "ExtraServices");
        }
    }
}
