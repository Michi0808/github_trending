<template>
    <div class="flex flex-col md:flex-row gap-2 mb-6">
      <!-- 🔎 Search Input -->
      <input
        type="text"
        v-model="searchQuery"
        placeholder="Search by repository name..."
        class="p-2 border rounded w-full md:w-1/3 bg-gray-800 text-white"
      />

      <!-- 🌍 Language Filter -->
      <select v-model="selectedLanguage" class="p-2 border rounded w-full md:w-1/4 bg-gray-800 text-white">
        <option value="">All Languages</option>
        <option v-for="lang in languages" :key="lang" :value="lang">{{ lang }}</option>
      </select>

      <!-- ⭐ Minimum Stars -->
      <input
        type="number"
        v-model.number="minStars"
        placeholder="Min Stars"
        class="p-2 border rounded w-full md:w-1/4 bg-gray-800 text-white"
      />

      <!-- 🔍 Search Button -->
      <button @click="submitFilters" class="p-2 bg-blue-500 text-white rounded">
        Search
      </button>
    </div>
  </template>

  <script>
  import { ref, watch, onMounted } from "vue";

  export default {
    props: ["languages"],
    emits: ["applyFilters"],
    setup(_, { emit }) {
      // 🎯 Search Conditions
      const searchQuery = ref(localStorage.getItem("searchQuery") || "");
      const selectedLanguage = ref(localStorage.getItem("selectedLanguage") || "");
      const minStars = ref(Number(localStorage.getItem("minStars")) || 0);

      // 🌍 Save to localStorage when values change
      watch([searchQuery, selectedLanguage, minStars], () => {
        localStorage.setItem("searchQuery", searchQuery.value);
        localStorage.setItem("selectedLanguage", selectedLanguage.value);
        localStorage.setItem("minStars", minStars.value);
      });

      // 🚀 Emit event to apply filters
      const submitFilters = () => {
        emit("applyFilters", {
          searchQuery: searchQuery.value,
          selectedLanguage: selectedLanguage.value,
          minStars: minStars.value
        });
      };

      return {
        searchQuery,
        selectedLanguage,
        minStars,
        submitFilters
      };
    }
  };
  </script>
