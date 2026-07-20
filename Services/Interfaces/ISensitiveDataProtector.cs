namespace marriage_hall_backend.Services.Interfaces
{
    public interface ISensitiveDataProtector
    {
        string Protect(string plaintext);
        string Unprotect(string protectedValue);
        string ComputeLookupHash(string normalizedValue);
    }
}
