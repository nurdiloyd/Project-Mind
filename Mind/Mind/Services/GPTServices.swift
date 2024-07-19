import Foundation

struct GPTResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

class GPTService {
    let apiUrl = "https://api.openai.com/v1/chat/completions"
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

    func fetchMeaning(for title: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let prompt = "What is the meaning of \(title)?"
        let messages: [[String: String]] = [
            ["role": "user", "content": prompt]
        ]
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 50
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received from the API")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(GPTResponse.self, from: data)
                let meaning = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Meaning: \(meaning ?? "Invalid Meaning")")
                completion(meaning)
            } catch {
                print("Failed to decode JSON response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
