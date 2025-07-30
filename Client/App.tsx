import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  FlatList,
  TextInput,
  Alert,
  SafeAreaView,
  StatusBar,
} from 'react-native';

// Configure the API base URL - update this to match your server
const API_BASE_URL = 'https://localhost:7000/api';

interface WeatherData {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

export default function App() {
  const [weatherData, setWeatherData] = useState<WeatherData[]>([]);
  const [loading, setLoading] = useState(false);
  const [newSummary, setNewSummary] = useState('');

  const fetchWeatherData = async () => {
    try {
      setLoading(true);
      // Using fetch instead of axios to avoid external dependencies
      const response = await fetch(`${API_BASE_URL}/WeatherForecast`);
      if (response.ok) {
        const data = await response.json();
        setWeatherData(data);
      } else {
        throw new Error('Failed to fetch data');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to fetch weather data. Make sure the server is running.');
      console.error('API Error:', error);
    } finally {
      setLoading(false);
    }
  };

  const addWeatherEntry = async () => {
    if (!newSummary.trim()) {
      Alert.alert('Error', 'Please enter a weather summary');
      return;
    }

    try {
      const newEntry = {
        date: new Date().toISOString(),
        temperatureC: Math.floor(Math.random() * 35) + 5,
        temperatureF: 0, // Will be calculated on server
        summary: newSummary.trim()
      };

      // In a real app, you would POST this to your API
      // For now, we'll just add it locally
      setWeatherData(prev => [...prev, { ...newEntry, temperatureF: Math.floor(newEntry.temperatureC * 9/5) + 32 }]);
      setNewSummary('');
      Alert.alert('Success', 'Weather entry added!');
    } catch (error) {
      Alert.alert('Error', 'Failed to add weather entry');
    }
  };

  useEffect(() => {
    fetchWeatherData();
  }, []);

  const renderWeatherItem = ({ item }: { item: WeatherData }) => (
    <View style={styles.weatherItem}>
      <Text style={styles.date}>{new Date(item.date).toLocaleDateString()}</Text>
      <Text style={styles.temperature}>{item.temperatureC}°C / {item.temperatureF}°F</Text>
      <Text style={styles.summary}>{item.summary}</Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#f0f0f0" />
      
      <View style={styles.header}>
        <Text style={styles.title}>VibeCoding Weather App</Text>
        <Text style={styles.subtitle}>React Native + .NET Core 8</Text>
      </View>

      <View style={styles.inputSection}>
        <TextInput
          style={styles.input}
          placeholder="Enter weather summary..."
          value={newSummary}
          onChangeText={setNewSummary}
        />
        <TouchableOpacity style={styles.addButton} onPress={addWeatherEntry}>
          <Text style={styles.addButtonText}>Add Entry</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.actionButtons}>
        <TouchableOpacity 
          style={[styles.button, loading && styles.buttonDisabled]} 
          onPress={fetchWeatherData}
          disabled={loading}
        >
          <Text style={styles.buttonText}>
            {loading ? 'Loading...' : 'Refresh Data'}
          </Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={weatherData}
        renderItem={renderWeatherItem}
        keyExtractor={(item, index) => `${item.date}-${index}`}
        style={styles.list}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <Text style={styles.emptyText}>
              {loading ? 'Loading weather data...' : 'No weather data available'}
            </Text>
            <Text style={styles.emptySubtext}>
              {!loading && 'Make sure your .NET server is running on https://localhost:7000'}
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f0f0',
  },
  header: {
    alignItems: 'center',
    paddingVertical: 20,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
  inputSection: {
    flexDirection: 'row',
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginRight: 10,
    fontSize: 16,
  },
  addButton: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    justifyContent: 'center',
  },
  addButtonText: {
    color: '#ffffff',
    fontWeight: '600',
    fontSize: 16,
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'center',
    padding: 16,
    backgroundColor: '#ffffff',
  },
  button: {
    backgroundColor: '#34C759',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
    marginHorizontal: 8,
  },
  buttonDisabled: {
    backgroundColor: '#999',
  },
  buttonText: {
    color: '#ffffff',
    fontWeight: '600',
    fontSize: 16,
  },
  list: {
    flex: 1,
    padding: 16,
  },
  weatherItem: {
    backgroundColor: '#ffffff',
    padding: 16,
    marginBottom: 12,
    borderRadius: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  date: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  temperature: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#007AFF',
    marginBottom: 4,
  },
  summary: {
    fontSize: 16,
    color: '#333',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    fontSize: 18,
    color: '#666',
    textAlign: 'center',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
});
