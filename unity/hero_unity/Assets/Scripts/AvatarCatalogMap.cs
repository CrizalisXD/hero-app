// AvatarCatalogMap.cs
// ────────────────────────────────────────────────────────────────────────────
// Maps a catalogue slot ("male top 02") to the mesh that renders it.
//
// Two delivery shapes are supported, because the two genders arrived
// differently and re-exporting one of them to match would be busywork:
//
//   • one FBX per garment           (female pack)  -> Item(file)
//   • one FBX with everything in it (male pack)    -> Item(file, mesh)
//
// The mesh names are the Blender object names, kept verbatim on purpose: they
// are what the artist sees in the outliner, so a mismatch is obvious to both
// of us. Adding an item is one line here plus a row in `avatar_assets`.
// ────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;

public readonly struct AvatarItem
{
    public AvatarItem(string file, string mesh = null)
    {
        File = file;
        Mesh = mesh;
    }

    /// Resource path under `Avatar/{Gender}/`.
    public string File { get; }

    /// Object name inside that file, or null when the file IS the item.
    public string Mesh { get; }

    public bool IsEmpty => string.IsNullOrEmpty(File);
}

public static class AvatarCatalogMap
{
    private const string WardrobeA = "Wardrobe_Male_A"; // причёски, шорты, casual
    private const string WardrobeB = "Wardrobe_Male_B"; // верх, брюки, обувь, костюм

    /// Face parts that are always worn, pulled out of the wardrobe files.
    /// The body FBX carries only the eyeballs, so brows and lashes come from
    /// here — without them the hero stares out of a bare face.
    public static readonly AvatarItem[] MaleFace =
    {
        new(WardrobeA, "Human.mindfront_eyebrows_07"),
        new(WardrobeA, "Human.mindfront_eyelashes_04"),
    };

    private static readonly Dictionary<string, AvatarItem> Items = new()
    {
        // ── Male: everything lives inside the two wardrobe files ──
        { "male_top_01", new AvatarItem(WardrobeB, "Human.namuhekam_male_polo_shirt") },
        { "male_top_02", new AvatarItem(WardrobeB, "Human.toigo_fisherman_sweater") },
        { "male_top_03", new AvatarItem(WardrobeB, "Human.mindfront_lusekofta") },

        { "male_bottom_01", new AvatarItem(WardrobeB, "Human.punkduck_male_classic_jeans") },
        { "male_bottom_02", new AvatarItem(WardrobeB, "Human.mindfront_male_trousers_1") },
        { "male_bottom_03", new AvatarItem(WardrobeB, "Human.mindfront_male_trousers_2") },

        { "male_shoes_01", new AvatarItem(WardrobeB, "Human.shoes01") },
        { "male_shoes_02", new AvatarItem(WardrobeB, "Human.shoes02") },
        { "male_shoes_03", new AvatarItem(WardrobeB, "Human.shoes04") },
        { "male_shoes_04", new AvatarItem(WardrobeB, "Human.shoes05") },
        { "male_shoes_05", new AvatarItem(WardrobeA, "Human.shoes06") },

        // `short01/02/04` — это ПРИЧЁСКИ MakeHuman, а не шорты: имя вводит в
        // заблуждение, и из-за него волосы сначала попали в слот «низ».
        { "male_hair_01", new AvatarItem(WardrobeA, "Human.culturalibre_hair_02") },
        { "male_hair_02", new AvatarItem(WardrobeA, "Human.culturalibre_hair_05") },
        { "male_hair_03", new AvatarItem(WardrobeA, "Human.elvs_braided_rows") },
        { "male_hair_04", new AvatarItem(WardrobeA, "Human.short01") },
        { "male_hair_05", new AvatarItem(WardrobeA, "Human.short02") },
        { "male_hair_06", new AvatarItem(WardrobeA, "Human.short04") },

        // Цельные образы — заменяют верх и низ разом.
        { "male_outfit_01", new AvatarItem(WardrobeA, "Human.male_casualsuit03") },
        { "male_outfit_02", new AvatarItem(WardrobeB, "Human.toigo_male_suit_3") },
    };

    /// Resolves `{gender}_{slot}_{index}`; returns an empty item when the pack
    /// has nothing for it, so a stale catalogue row leaves the slot empty
    /// instead of throwing.
    public static AvatarItem Resolve(string gender, string slot, int index)
    {
        var key = $"{gender}_{slot}_{index:00}".ToLowerInvariant();
        return Items.TryGetValue(key, out var item) ? item : default;
    }

    public static bool Has(string gender) => gender == "male";

    /// Every mapped item as (`unity_asset_id`, item) — the id is the one the
    /// `avatar_assets` catalogue stores, so previews rendered under that name
    /// line up with the cards the app draws.
    public static IEnumerable<KeyValuePair<string, AvatarItem>> All()
    {
        foreach (var entry in Items)
        {
            var parts = entry.Key.Split('_'); // male_top_01
            if (parts.Length != 3) continue;

            var gender = char.ToUpperInvariant(parts[0][0]) + parts[0].Substring(1);
            var slot = char.ToUpperInvariant(parts[1][0]) + parts[1].Substring(1);
            yield return new KeyValuePair<string, AvatarItem>(
                $"{slot}_{gender}_{parts[2]}", entry.Value);
        }
    }
}
