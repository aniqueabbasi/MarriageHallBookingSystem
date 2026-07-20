namespace marriage_hall_backend.Helpers
{
    /// Produces the one canonical representation of a CNIC number used
    /// consistently for encryption, HMAC hashing, and last-4 extraction.
    public static class CnicNormalizer
    {
        public static string Normalize(string rawCnicNumber)
        {
            var digitsOnly = new string(rawCnicNumber.Where(char.IsDigit).ToArray());
            if (digitsOnly.Length != 13)
                throw new BadRequestException("CNIC number must contain exactly 13 digits.");

            return $"{digitsOnly[..5]}-{digitsOnly[5..12]}-{digitsOnly[12..]}";
        }

        public static string ExtractLast4(string canonicalCnic) => canonicalCnic.Replace("-", "")[^4..];
    }
}
