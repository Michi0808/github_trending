<script setup>
import { ref, onMounted } from "vue";
import { supabase } from "../lib/supabase";

const repositories = ref([]);

const fetchRepositories = async () => {
  const { data, error } = await supabase.from("repositories").select("*").order("stars", { ascending: false });

  if (error) {
    console.error("Error fetching repositories:", error);
  } else {
    repositories.value = data;
  }
};

onMounted(fetchRepositories);
</script>

<template>
  <div>
    <h1>GitHub Trending Repositories</h1>
    <ul>
      <li v-for="repo in repositories" :key="repo.id">
        <a :href="repo.url" target="_blank">{{ repo.repo_name }}</a> - {{ repo.stars }} ⭐ ({{ repo.language || "Unknown" }})
      </li>
    </ul>
  </div>
</template>
