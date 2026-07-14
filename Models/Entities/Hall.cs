namespace marriage_hall_backend.Models.Entities
{
    public class Hall
    {
        public int Id { get; set; }
        public int OwnerId { get; set; }
        public User Owner { get; set; } = null!;

        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<HallImage> Images { get; set; } = new List<HallImage>();
        public ICollection<VirtualTour> VirtualTours { get; set; } = new List<VirtualTour>();
        public ICollection<FoodPackage> FoodPackages { get; set; } = new List<FoodPackage>();
        public ICollection<ExtraService> ExtraServices { get; set; } = new List<ExtraService>();
        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    }
}
