<template>
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold text-center mb-6">GitHub Trending Repositories</h1>

      <!-- 🔎 Search Form -->
      <SearchForm
        :languages="languages"
        @applyFilters="applyFilters"
      />

      <!-- 📊 Repository Table -->
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
            <tr v-for="repo in filteredRepositories" :key="repo.id" class="border-b hover:bg-gray-700">
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
    </div>
  </template>

  <script>
  import { ref, computed, onMounted } from "vue";
  import SearchForm from "./components/SearchForm.vue";
  import axios from "axios";

  // 🔹 API Base URL from environment variables
  const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

  export default {
    components: { SearchForm },
    setup() {
      const repositories = ref([]);
      const searchQuery = ref("");
      const selectedLanguage = ref("");
      const minStars = ref(0);
      const languages = ref([]);

      // 🔹 Fetch repository data from Laravel API
      const fetchRepositories = async () => {
        try {
          const response = await axios.get(`${API_BASE_URL}/api/repositories`);
          repositories.value = response.data;

          // Extract unique programming languages
          languages.value = [...new Set(response.data.map(repo => repo.language).filter(Boolean))];
        } catch (error) {
          console.error("Error fetching repositories:", error);
        }
      };

      // 🔍 Apply search filters and update localStorage
      const applyFilters = (filters) => {
        searchQuery.value = filters.searchQuery;
        selectedLanguage.value = filters.selectedLanguage;
        minStars.value = filters.minStars;

        localStorage.setItem("searchQuery", filters.searchQuery);
        localStorage.setItem("selectedLanguage", filters.selectedLanguage);
        localStorage.setItem("minStars", filters.minStars);
      };

      // 🔍 Filter repositories
      const filteredRepositories = computed(() => {
        return repositories.value.filter(repo => {
          return (
            repo.repo_name.toLowerCase().includes(searchQuery.value.toLowerCase()) &&
            (!selectedLanguage.value || repo.language === selectedLanguage.value) &&
            repo.stars >= minStars.value
          );
        });
      });

      // 🚀 Load repositories on mount
      onMounted(() => {
        // Restore saved filters
        searchQuery.value = localStorage.getItem("searchQuery") || "";
        selectedLanguage.value = localStorage.getItem("selectedLanguage") || "";
        minStars.value = Number(localStorage.getItem("minStars")) || 0;

        fetchRepositories();
      });

      return {
        repositories,
        searchQuery,
        selectedLanguage,
        minStars,
        languages,
        fetchRepositories,
        filteredRepositories,
        applyFilters
      };
    }
  };
  </script>
