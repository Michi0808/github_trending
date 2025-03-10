<script setup>
import { ref, computed, onMounted } from "vue";
import { createClient } from "@supabase/supabase-js";

// 🔹 Initialize Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// 🔹 State variables
const repositories = ref([]); // Repository data
const searchQuery = ref(""); // Search input
const selectedLanguage = ref(""); // Language filter
const minStars = ref(0); // Minimum stars filter
const languages = ref([]); // List of languages
const currentPage = ref(1); // Current page number
const itemsPerPage = 10; // Items per page

// 🔹 Fetch repositories from Supabase
const fetchRepositories = async () => {
  const { data, error } = await supabase.from("repositories").select("*");
  if (error) {
    console.error("Error fetching repositories:", error);
  } else {
    repositories.value = data;

    // Extract unique languages from fetched data
    languages.value = [...new Set(data.map(repo => repo.language).filter(Boolean))];
  }
};

// 🔍 Apply filters and search
const filteredRepositories = computed(() => {
  return repositories.value.filter(repo => {
    const matchesQuery = repo.repo_name.toLowerCase().includes(searchQuery.value.toLowerCase());
    const matchesLanguage = selectedLanguage.value ? repo.language === selectedLanguage.value : true;
    const matchesStars = repo.stars >= minStars.value;

    return matchesQuery && matchesLanguage && matchesStars;
  });
});

// 📌 Compute total pages
const totalPages = computed(() => Math.ceil(filteredRepositories.value.length / itemsPerPage));

// 📌 Paginate the filtered results
const paginatedRepositories = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredRepositories.value.slice(start, start + itemsPerPage);
});

// 🔹 Change page
const setPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

// Fetch repositories on mount
onMounted(fetchRepositories);
</script>

<template>
  <div class="container mx-auto p-6">
    <h1 class="text-3xl font-bold text-center text-white mb-6">GitHub Trending Repositories</h1>

    <!-- 🔎 Search & Filters -->
    <div class="flex flex-col md:flex-row gap-2 mb-6">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search by repository name..."
        class="p-2 border border-gray-400 bg-white text-black rounded w-full md:w-1/3"
      />
      <select v-model="selectedLanguage" class="p-2 border border-gray-400 bg-white text-black rounded w-full md:w-1/4">
        <option value="">All Languages</option>
        <option v-for="lang in languages" :key="lang" :value="lang">{{ lang }}</option>
      </select>
      <input
        type="number"
        v-model.number="minStars"
        placeholder="Min Stars"
        class="p-2 border border-gray-400 bg-white text-black rounded w-full md:w-1/4"
      />
      <button @click="fetchRepositories" class="p-2 bg-blue-500 text-white rounded">Search</button>
    </div>

    <!-- 🔹 Repository List -->
    <div class="overflow-x-auto">
      <table class="min-w-full bg-gray-900 text-white border border-gray-700 rounded-lg">
        <thead class="bg-gray-800">
          <tr>
            <th class="py-2 px-4 border-b">Repository</th>
            <th class="py-2 px-4 border-b">Stars</th>
            <th class="py-2 px-4 border-b">Language</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="repo in paginatedRepositories" :key="repo.id" class="border-b hover:bg-gray-700">
            <td class="py-2 px-4">
              <a :href="repo.url" target="_blank" class="text-blue-400 hover:underline">
                {{ repo.repo_name }}
              </a>
            </td>
            <td class="py-2 px-4 text-yellow-400">⭐ {{ repo.stars }}</td>
            <td class="py-2 px-4">{{ repo.language || "Unknown" }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 📌 Pagination Controls -->
    <div class="flex justify-center mt-4 space-x-2">
      <button @click="setPage(currentPage - 1)" :disabled="currentPage === 1"
        class="bg-gray-500 text-white px-3 py-2 rounded disabled:opacity-50">
        Prev
      </button>

      <button
        v-for="page in totalPages"
        :key="page"
        @click="setPage(page)"
        class="px-3 py-2 rounded"
        :class="page === currentPage ? 'bg-blue-500 text-white' : 'bg-gray-700 text-white'"
      >
        {{ page }}
      </button>

      <button @click="setPage(currentPage + 1)" :disabled="currentPage === totalPages"
        class="bg-gray-500 text-white px-3 py-2 rounded disabled:opacity-50">
        Next
      </button>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 800px;
}
</style>
