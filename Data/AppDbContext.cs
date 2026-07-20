using marriage_hall_backend.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users => Set<User>();
        public DbSet<Hall> Halls => Set<Hall>();
        public DbSet<HallImage> HallImages => Set<HallImage>();
        public DbSet<VirtualTour> VirtualTours => Set<VirtualTour>();
        public DbSet<FoodPackage> FoodPackages => Set<FoodPackage>();
        public DbSet<ExtraService> ExtraServices => Set<ExtraService>();
        public DbSet<Booking> Bookings => Set<Booking>();
        public DbSet<BookingExtraService> BookingExtraServices => Set<BookingExtraService>();
        public DbSet<Payment> Payments => Set<Payment>();
        public DbSet<Review> Reviews => Set<Review>();
        public DbSet<Favorite> Favorites => Set<Favorite>();
        public DbSet<Notification> Notifications => Set<Notification>();
        public DbSet<PasswordResetOtp> PasswordResetOtps => Set<PasswordResetOtp>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // ---- User ----
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.Email).IsUnique();
            });

            // ---- Hall ----
            modelBuilder.Entity<Hall>(entity =>
            {
                entity.Property(h => h.PricePerDay).HasPrecision(12, 2);

                entity.HasOne(h => h.Owner)
                    .WithMany(u => u.HallsOwned)
                    .HasForeignKey(h => h.OwnerId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // ---- HallImage ----
            modelBuilder.Entity<HallImage>(entity =>
            {
                entity.HasOne(i => i.Hall)
                    .WithMany(h => h.Images)
                    .HasForeignKey(i => i.HallId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- VirtualTour ----
            modelBuilder.Entity<VirtualTour>(entity =>
            {
                entity.Property(t => t.IsActive).HasDefaultValue(true);

                entity.HasOne(t => t.Hall)
                    .WithMany(h => h.VirtualTours)
                    .HasForeignKey(t => t.HallId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- FoodPackage ----
            modelBuilder.Entity<FoodPackage>(entity =>
            {
                entity.Property(f => f.PricePerHead).HasPrecision(12, 2);
                entity.Property(f => f.IsActive).HasDefaultValue(true);

                entity.HasOne(f => f.Hall)
                    .WithMany(h => h.FoodPackages)
                    .HasForeignKey(f => f.HallId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- ExtraService ----
            modelBuilder.Entity<ExtraService>(entity =>
            {
                entity.Property(e => e.Price).HasPrecision(12, 2);
                entity.Property(e => e.IsActive).HasDefaultValue(true);

                entity.HasOne(e => e.Hall)
                    .WithMany(h => h.ExtraServices)
                    .HasForeignKey(e => e.HallId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- Booking ----
            modelBuilder.Entity<Booking>(entity =>
            {
                entity.Property(b => b.TotalAmount).HasPrecision(12, 2);
                entity.Property(b => b.AdvanceAmount).HasPrecision(12, 2);

                entity.HasOne(b => b.User)
                    .WithMany(u => u.Bookings)
                    .HasForeignKey(b => b.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(b => b.Hall)
                    .WithMany(h => h.Bookings)
                    .HasForeignKey(b => b.HallId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(b => b.FoodPackage)
                    .WithMany(f => f.Bookings)
                    .HasForeignKey(b => b.FoodPackageId)
                    .OnDelete(DeleteBehavior.SetNull);
            });

            // ---- BookingExtraService (join entity) ----
            modelBuilder.Entity<BookingExtraService>(entity =>
            {
                entity.Property(x => x.Price).HasPrecision(12, 2);

                entity.HasOne(x => x.Booking)
                    .WithMany(b => b.ExtraServices)
                    .HasForeignKey(x => x.BookingId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(x => x.ExtraService)
                    .WithMany(e => e.BookingExtraServices)
                    .HasForeignKey(x => x.ExtraServiceId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // ---- Payment ----
            modelBuilder.Entity<Payment>(entity =>
            {
                entity.Property(p => p.Amount).HasPrecision(12, 2);

                entity.HasOne(p => p.Booking)
                    .WithMany(b => b.Payments)
                    .HasForeignKey(p => p.BookingId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- Review ----
            modelBuilder.Entity<Review>(entity =>
            {
                entity.HasIndex(r => r.BookingId).IsUnique();

                entity.HasOne(r => r.User)
                    .WithMany(u => u.Reviews)
                    .HasForeignKey(r => r.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(r => r.Hall)
                    .WithMany(h => h.Reviews)
                    .HasForeignKey(r => r.HallId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(r => r.Booking)
                    .WithOne(b => b.Review)
                    .HasForeignKey<Review>(r => r.BookingId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // ---- Favorite ----
            modelBuilder.Entity<Favorite>(entity =>
            {
                entity.HasIndex(f => new { f.UserId, f.HallId }).IsUnique();

                entity.HasOne(f => f.User)
                    .WithMany(u => u.Favorites)
                    .HasForeignKey(f => f.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(f => f.Hall)
                    .WithMany(h => h.Favorites)
                    .HasForeignKey(f => f.HallId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- Notification ----
            modelBuilder.Entity<Notification>(entity =>
            {
                entity.HasOne(n => n.User)
                    .WithMany(u => u.Notifications)
                    .HasForeignKey(n => n.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ---- PasswordResetOtp ----
            modelBuilder.Entity<PasswordResetOtp>(entity =>
            {
                entity.HasOne(o => o.User)
                    .WithMany(u => u.PasswordResetOtps)
                    .HasForeignKey(o => o.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });
        }
    }
}
