namespace marriage_hall_backend.DTOs.Halls
{
    public class HallDetailDto
    {
        public int Id { get; set; }
        public int OwnerId { get; set; }
        public string OwnerName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
        public bool IsActive { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }

        public List<HallImageDto> Images { get; set; } = new();
        public List<VirtualTourDto> VirtualTours { get; set; } = new();
        public List<FoodPackageDto> FoodPackages { get; set; } = new();
        public List<ExtraServiceDto> ExtraServices { get; set; } = new();
    }
}
