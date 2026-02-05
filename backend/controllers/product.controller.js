const NodeCache = require("node-cache");
const recommendationCache = new NodeCache({ stdTTL: 3600 });

let frontendArray = [];
let sohamArray = [];

// ---------------------- Helper ----------------------
function addToArrays({
  imageUrl,
  name,
  productLink,
  rating,
  price,
  description,
  productId,
  tags,
}) {
  frontendArray.push({
    imageUrl: imageUrl || "",
    name: name || "",
    productLink: productLink || "",
    rating: rating || "",
    price: price || "",
    description: description || "",
    productId: productId || "",
  });

  sohamArray.push({
    productId: productId || "",
    productLink: productLink || "",
    name: name || "",
    description: description || "",
    tags: tags || [],
  });
}

// ---------------------- MAIN CONTROLLER ----------------------
const getRecommendedProducts = async (req, res) => {
  try {
    // 1) Take query from frontend
    const item = req.query.item?.trim() || "baby products";

    // 2) Check cache
    const cached = recommendationCache.get(item);
    if (cached) {
      return res.status(200).json({
        success: true,
        fromCache: true,
        query: item,
        results: cached,
      });
    }

    // 3) Reset arrays
    frontendArray = [];
    sohamArray = [];

    // 4) Call all search services
    await Promise.all([
      searchMeesho(item),
      searchShoppersStop(item),
      searchNykaa(item),
    ]);

    // 5) Filter duplicates / similar products
    const filteredSoham = await cosineSimilarityFilter(sohamArray);

    // 6) Match filtered with frontend format
    const finalResults = frontendArray.filter((f) =>
      filteredSoham.some((s) => s.productLink === f.productLink)
    );

    // 7) Save in cache
    recommendationCache.set(item, finalResults);

    // 8) Send response to frontend
    return res.status(200).json({
      success: true,
      fromCache: false,
      query: item,
      count: finalResults.length,
      results: finalResults,
    });
  } catch (error) {
    console.error("getRecommendedProducts error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch products",
      error: error.message,
    });
  }
};

module.exports = { getRecommendedProducts };

