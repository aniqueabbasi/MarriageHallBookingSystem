namespace marriage_hall_backend.Models.Enums
{
    public enum UserRole
    {
        Customer,
        HallOwner,
        Admin
    }

    public enum BookingStatus
    {
        Pending,
        Confirmed,
        Completed,
        Cancelled,
        Rejected
    }

    public enum PaymentStatus
    {
        Pending,
        Completed,
        Failed,
        Refunded
    }

    public enum PaymentMethod
    {
        Cash,
        CreditCard,
        DebitCard,
        BankTransfer,
        JazzCash,
        EasyPaisa
    }

    public enum NotificationType
    {
        BookingRequested,
        BookingConfirmed,
        BookingRejected,
        BookingCancelled,
        PaymentReceived,
        ReviewReminder,
        General
    }
}
