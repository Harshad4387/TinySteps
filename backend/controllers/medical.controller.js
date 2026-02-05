const axios = require("axios");

/**
 * Extracts price from Netmeds product page HTML
 * (Netmeds does not provide price in autocomplete API)
 */
const extractPriceFromHtml = (html) => {
  if (!html) return null;

  // Try multiple patterns because site HTML can change
  const patterns = [
    /"final_price"\s*:\s*"([^"]+)"/,
    /"price"\s*:\s*"([^"]+)"/,
    /"mrp"\s*:\s*"([^"]+)"/
  ];

  for (const p of patterns) {
    const match = html.match(p);
    if (match && match[1]) {
      const cleaned = match[1]
        .toString()
        .replace(/₹/g, "")
        .replace(/,/g, "")
        .trim();

      const num = Number(cleaned);
      return isNaN(num) ? null : num;
    }
  }

  return null;
};

const searchMedicine = async (req, res) => {
  try {
    const q = (req.query.q || "").trim();

    if (!q) {
      return res.json({
        query: "",
        queries: [],
        products: []
      });
    }

    // 1) Call autocomplete API
    const autoCompleteUrl =
      "https://www.netmeds.com/ext/search/application/api/v1.0/auto-complete?q=" +
      encodeURIComponent(q);

    const autoRes = await axios.get(autoCompleteUrl);
    const items = autoRes.data?.items || [];

    const queriesSet = new Set();
    const products = [];

    // 2) Clean the autocomplete response
    for (const item of items) {
      const type = item?.type || "";

      // Query suggestions
      if (type === "product" && item?.display && item?.action?.page?.type === "products") {
        queriesSet.add(item.display);
      }

      // Actual product results
      if (type === "product" && item?.action?.page?.type === "product") {
        const slug = item?.action?.page?.params?.slug?.[0] || "";
        const name = item?.display || "";
        const image = item?.logo?.url || "";

        if (slug) {
          products.push({
            name,
            slug,
            image
          });
        }
      }
    }

    // 3) Fetch price for top 5 products (to avoid slow API)
    const topProducts = products.slice(0, 5);

    const productsWithPrice = await Promise.all(
      topProducts.map(async (p) => {
        try {
          const productPageUrl = `https://www.netmeds.com/prescriptions/${p.slug}`;

          const productRes = await axios.get(productPageUrl, {
            headers: {
              "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
            }
          });

          const html = productRes.data;
          const price = extractPriceFromHtml(html);

          return {
            ...p,
            price
          };
        } catch (err) {
          return {
            ...p,
            price: null
          };
        }
      })
    );

    // 4) Final clean response
    return res.json({
      query: q,
      queries: Array.from(queriesSet),
      products: productsWithPrice
    });
  } catch (error) {
    console.log("Medicine Search Error:", error.message);

    return res.status(500).json({
      error: "Failed to fetch medicine suggestions"
    });
  }
};

module.exports = {
  searchMedicine
};
