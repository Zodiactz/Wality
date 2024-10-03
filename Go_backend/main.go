package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"cloud.google.com/go/storage"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Define a MongoDB client variable
var client *mongo.Client

// Define Firebase storage bucket variable
var bucket *storage.BucketHandle

func main() {
    // MongoDB connection URI
    uri := "mongodb+srv://notephotogame:0834965642Abc@clusterwality.wh4zl.mongodb.net/?retryWrites=true&w=majority"
    serverAPI := options.ServerAPI(options.ServerAPIVersion1)
    opts := options.Client().ApplyURI(uri).SetServerAPIOptions(serverAPI)

    // Create a new client and connect to the server
    var err error
    client, err = mongo.Connect(context.TODO(), opts)
    if err != nil {
        log.Fatal(err)
    }

    // Ping the MongoDB server to check the connection
    if err := client.Ping(context.TODO(), nil); err != nil {
        log.Fatal(err)
    }
    fmt.Println("Connected to MongoDB!")

    	// Initialize Firebase Storage (assumes you have a service account JSON file)
	err = initializeFirebase()
	if err != nil {
		log.Fatalf("Failed to initialize Firebase: %v", err)
	}

    // Create a new Fiber app
    app := fiber.New()

    // Define routes
    app.Post("/create", createPerson)
    app.Get("/users/:username", getPerson)
    app.Get("/userId/:user_id", getUserById)
    app.Get("/waterId/:waterId", getWaterById)
    app.Put("/update/:name", updatePerson)
    app.Delete("/delete/:user_id", deleteUsers)
    app.Post("/updateUserWater/:user_id", updateUserWater)
    app.Post("/updateUserFillingTime/:user_id", updateUserFillingTime)
    app.Post("/updateWaterStatus/:waterId", updateWaterStatus)
    app.Get("/getImage", getImageFromDynamicLink)//use
    app.Post("/createCoupon", createCoupon)
    app.Get("/getAllCoupons", getAllCoupons)
    app.Post("/updateUserCouponCheck/:user_id", addCouponCheck)
    app.Get("/getCoupons/:user_id", getCouponsFromUser)
    app.Post("/updateUsername/:user_id", updateUsername)
    app.Post("/updateEmail/:user_id", updateUserEmail)
    app.Post("/reset-password", resetPassword)
    app.Post("/reset-password/:token", resetPasswordWithToken)
    app.Get("/getAllUsers", getAllUsers)
    app.Get("/update", getAllUsers)
    app.Post("/updateUserId/:email", updateUserIdByEmail)
	app.Post("/updateImage/:user_id", updateImage)
    app.Delete("/deleteOldImage", deleteImage)
    app.Delete("/deleteUserByEmail/:email", deleteUsersByEmail)



    // New route for image upload
	app.Post("/uploadImage", uploadImage)

    // Start the server
    log.Fatal(app.Listen(":8080"))
}
// Initialize Firebase storage
func initializeFirebase() error {
	// Set environment variable for Firebase credentials (or use your method)
	os.Setenv("GOOGLE_APPLICATION_CREDENTIALS", "key/walityfirebase-firebase-adminsdk-f5qqz-5c4256b53e.json")

	// Create a new Firebase storage client
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create Firebase storage client: %v", err)
	}

	// Get a reference to your storage bucket
	bucket = client.Bucket("walityfirebase.appspot.com")
	if bucket == nil {
		return fmt.Errorf("failed to access Firebase storage bucket")
	}
	return nil
}

// Upload an image to Firebase storage
func uploadImage(c *fiber.Ctx) error {
	// Get the uploaded file from the form data
	fileHeader, err := c.FormFile("image")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Failed to get image"})
	}

	// Open the uploaded file
	file, err := fileHeader.Open()
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to open image file"})
	}
	defer file.Close()

	// Upload the file to Firebase Storage
	uploadedURL, err := uploadToFirebaseStorage(fileHeader.Filename, file)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to upload image"})
	}

	// Return the URL of the uploaded image
	return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Image uploaded successfully", "imageURL": uploadedURL})
}

// Function to upload image to Firebase Storage
func uploadToFirebaseStorage(fileName string, file multipart.File) (string, error) {
	ctx := context.Background()

	// Generate a unique identifier (could be timestamp, UUID, or random string)
	uniqueID := generateRandomString(8)
	uniqueFileName := fmt.Sprintf("%s-%s", uniqueID, fileName)

	// Create an object in the bucket with the unique filename
	object := bucket.Object(uniqueFileName)
	writer := object.NewWriter(ctx)
	writer.ContentType = "image/jpeg" // Set appropriate content type for your image

	// Write file data to Firebase Storage
	if _, err := io.Copy(writer, file); err != nil {
		writer.Close()
		return "", fmt.Errorf("failed to write file to Firebase Storage: %v", err)
	}

	// Close the writer
	if err := writer.Close(); err != nil {
		return "", fmt.Errorf("failed to close writer: %v", err)
	}

	// Get the public URL of the uploaded image
	imageURL := fmt.Sprintf("https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media", "walityfirebase.appspot.com", url.QueryEscape(uniqueFileName))

	return imageURL, nil
}

func extractImageNameFromURL(imageURL string) (string, error) {
	// Parse the URL to ensure it's valid
	parsedUrl, err := url.Parse(imageURL)
	if err != nil {
		return "", fmt.Errorf("invalid URL: %v", err)
	}

	// Find the portion after "/o/" in the path
	pathSegments := strings.Split(parsedUrl.Path, "/o/")
	if len(pathSegments) < 2 {
		return "", fmt.Errorf("invalid Firebase Storage URL format")
	}

	// Extract the image name (which may still be URL-encoded)
	imageName := pathSegments[1]

	// Optionally decode the URL-encoded image name
	decodedImageName, err := url.QueryUnescape(imageName)
	if err != nil {
		return "", fmt.Errorf("failed to decode image name: %v", err)
	}

	return decodedImageName, nil
}


// Function to delete image from Firebase Storage
func deleteImage(c *fiber.Ctx) error {
    // Get the raw image URL from the query parameter
    imageURL := c.Query("imageURL")
    if imageURL == "" {
        // return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Image URL is required"})
        return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Image replace successfully"})
    }

    // Extract the image name from the image URL
    imageName, err := extractImageNameFromURL(imageURL)
    if err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid image URL", "details": err.Error()})
    }

    // Create a context
    ctx := context.Background()

    // Get a reference to the file in Firebase Storage
    object := bucket.Object(imageName)

    // Delete the file from Firebase Storage
    if err := object.Delete(ctx); err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to delete image", "details": err.Error()})
    }

    // Return success response
    return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Image deleted successfully"})
}



// Helper function to generate a random string of the given length
func generateRandomString(n int) string {
	bytes := make([]byte, n)
	_, err := rand.Read(bytes)
	if err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano()) // fallback to timestamp
	}
	return hex.EncodeToString(bytes)
}

// Create a new person
func createPerson(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    var person bson.M
    if err := c.BodyParser(&person); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }
    _, err := collection.InsertOne(context.Background(), person)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }
    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User created successfully!"})
}

// Get a person by name
func getPerson(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    username := c.Params("username")

    var result bson.M
    err := collection.FindOne(context.Background(), bson.M{"username": username}).Decode(&result)
    if err != nil {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "userName not found!"})
    }
    return c.Status(http.StatusOK).JSON(result)
}

func getUserById(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    var result bson.M
    err := collection.FindOne(context.Background(), bson.M{"user_id": user_id}).Decode(&result)
    if err != nil {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "user not found!"})
    }
    return c.Status(http.StatusOK).JSON(result)
}

// Update a person's information
func updatePerson(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    name := c.Params("name")

    var updatedInfo bson.M
    if err := c.BodyParser(&updatedInfo); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    filter := bson.M{"name": name}
    update := bson.M{"$set": updatedInfo}
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "Person not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Person updated successfully!"})
}

// Delete a person by name
func deleteUsers(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    result, err := collection.DeleteOne(context.Background(), bson.M{"user_id": user_id})
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    if result.DeletedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User deleted successfully!"})
}

func deleteUsersByEmail(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    email := c.Params("email")

    result, err := collection.DeleteOne(context.Background(), bson.M{"email": email})
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    if result.DeletedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User deleted successfully!"})
}

func getWaterById(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("QRwaterquantity")
    waterId := c.Params("waterId")

    var result bson.M
    err := collection.FindOne(context.Background(), bson.M{"waterId": waterId}).Decode(&result)
    if err != nil {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "qrWater not found!"})
    }
    return c.Status(http.StatusOK).JSON(result)
}

func updateUserWater(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the update payload without filling time
    var updatePayload struct {
        CurrentMl    int `json:"currentMl"`
        BotLiv       int `json:"botLiv"`
        TotalMl      int `json:"totalMl"`
        FillingLimit int `json:"fillingLimit"`
        EventBot     int `json:"eventBot"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    // Debug: Log the user_id and updatePayload
    fmt.Printf("Updating user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "currentMl":    updatePayload.CurrentMl,
            "botLiv":       updatePayload.BotLiv,
            "totalMl":      updatePayload.TotalMl,
            "fillingLimit": updatePayload.FillingLimit,
            "eventBot":     updatePayload.EventBot,
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User updated successfully!"})
}

func updateUserFillingTime(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the filling time update
    var updatePayload struct {
        StartFillingTime string `json:"startFillingTime"` // Keep this as string for input
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    // Convert StartFillingTime from string to time.Time
    startFillingTime, err := time.Parse(time.RFC3339, updatePayload.StartFillingTime) // Convert to time.Time
    if err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid date format"})
    }

    // Debug: Log the user_id and updatePayload
    fmt.Printf("Updating filling time for user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "startFillingTime": startFillingTime, // Store as time.Time
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Filling time updated successfully!"})
}



func updateWaterStatus(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("QRwaterquantity")
    waterId := c.Params("waterId")

    // Define a struct for the update payload
    var updatePayload struct {       
        Status string `json:"status"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    fmt.Printf("Updating water with ID: %s\n", waterId)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"waterId": waterId}
    update := bson.M{
        "$set": bson.M{
            "status": updatePayload.Status, // Match the struct field name
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "Water not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Water updated successfully!"})
}

func getImageFromDynamicLink(c *fiber.Ctx) error {
    // Extract the URL query parameter
    rawUrl := c.Query("url")

    // Log the raw URL for debugging purposes
    fmt.Println("Raw URL:", rawUrl)

    // Check if the URL is already encoded
    encodedUrl := url.QueryEscape(rawUrl)
    
    // Log the encoded URL for debugging purposes
    fmt.Println("Encoded URL:", encodedUrl)

    // Try fetching the image using the encoded URL
    resp, err := http.Get(rawUrl)  // Use the raw URL first, if that fails try encoded
    if err != nil {
        fmt.Println("Error fetching image:", err)
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch image from the URL"})
    }
    defer resp.Body.Close()

    // Check if the image was retrieved successfully
    if resp.StatusCode != http.StatusOK {
        fmt.Println("Failed to fetch image, status code:", resp.Status)
        return c.Status(resp.StatusCode).JSON(fiber.Map{"error": "Failed to fetch image, status code: " + resp.Status})
    }

    // Read the image data
    imageData, err := io.ReadAll(resp.Body)
    if err != nil {
        fmt.Println("Error reading image data:", err)
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to read image data"})
    }

    // Send the image back to the client
    c.Response().Header.Set(fiber.HeaderContentType, resp.Header.Get("Content-Type")) // Preserve the content type
    return c.Status(http.StatusOK).Send(imageData)
}

//// Create coupon
func createCoupon(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Reward")
    var person bson.M
    if err := c.BodyParser(&person); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }
    _, err := collection.InsertOne(context.Background(), person)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }
    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Coupon created successfully!"})
}

func getAllCoupons(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Reward")

    // Use Find() to get all records
    cursor, err := collection.Find(context.Background(), bson.M{})
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"status": "error", "message": "Could not fetch rewards"})
    }

    var rewards []bson.M
    if err := cursor.All(context.Background(), &rewards); err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"status": "error", "message": "Error while decoding rewards"})
    }

    return c.Status(http.StatusOK).JSON(rewards)
}

func addCouponCheck(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the request body
    var requestBody struct {
        Coupon string `json:"couponCheck"` // Field to hold the coupon value
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&requestBody); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$addToSet": bson.M{
            "couponCheck": requestBody.Coupon, // Add coupon to the array
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Coupon added to user successfully!"})
}

func getCouponsFromUser(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct to hold the user document
    var user struct {
        CouponCheck []string `bson:"couponCheck" json:"couponCheck"`
    }

    // Find the user by user_id
    err := collection.FindOne(context.Background(), bson.M{"user_id": user_id}).Decode(&user)
    if err != nil {
        if err == mongo.ErrNoDocuments {
            return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
        }
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Return the couponCheck array
    return c.Status(http.StatusOK).JSON(fiber.Map{"couponCheck": user.CouponCheck})
}
func updateUsername(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the update payload
    var updatePayload struct {       
        Username string `json:"username"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    fmt.Printf("Updating user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "username": updatePayload.Username, // Match the struct field name
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "username not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "username updated successfully!"})
}

func updateImage(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the update payload
    var updatePayload struct {       
        Image string `json:"profileImg_link"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    fmt.Printf("Updating user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "profileImg_link": updatePayload.Image, // Match the struct field name
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "image not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "image updated successfully!"})
}

// Update a user's email
func updateUserEmail(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the update payload
    var updatePayload struct {       
        Email string `json:"email"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    fmt.Printf("Updating user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "email": updatePayload.Email, // Update the email field
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User email updated successfully!"})
}


func resetPassword(c *fiber.Ctx) error {
    // Get the user's email from the request body
    var requestBody struct {
        Email string `json:"email"`
    }
    if err := c.BodyParser(&requestBody); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
    }

    // Find the user in the database by email
    collection := client.Database("Wality_DB").Collection("Users")
    var user bson.M
    err := collection.FindOne(context.Background(), bson.M{"email": requestBody.Email}).Decode(&user)
    if err != nil {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
    }

    // Generate a reset token
    resetToken := generateRandomString(32)
    tokenExpiration := time.Now().Add(1 * time.Hour) // Token expires in 1 hour

    // Update the user with the reset token and expiration
    update := bson.M{
        "$set": bson.M{
            "resetToken":     resetToken,
            "tokenExpiresAt": tokenExpiration,
        },
    }
    _, err = collection.UpdateOne(context.Background(), bson.M{"email": requestBody.Email}, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to generate reset token"})
    }

    // Send the reset email (this is just a placeholder, you'd need to integrate with an email service)
    resetLink := fmt.Sprintf("https://yourapp.com/reset-password?token=%s", resetToken)
    fmt.Printf("Password reset link for user: %s\n", resetLink)

    // Respond to the client
    return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Password reset link sent to your email"})
}

func resetPasswordWithToken(c *fiber.Ctx) error {
    // Get the reset token and new password from the request
    var requestBody struct {
        Token       string `json:"token"`
        NewPassword string `json:"newPassword"`
    }
    if err := c.BodyParser(&requestBody); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
    }

    // Find the user by reset token
    collection := client.Database("Wality_DB").Collection("Users")
    var user bson.M
    err := collection.FindOne(context.Background(), bson.M{"resetToken": requestBody.Token}).Decode(&user)
    if err != nil {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"error": "Invalid or expired token"})
    }

    // Check if the token has expired
    tokenExpiresAt := user["tokenExpiresAt"].(time.Time)
    if time.Now().After(tokenExpiresAt) {
        return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Reset token has expired"})
    }

    // Hash the new password (for security)
    hashedPassword := hashPassword(requestBody.NewPassword)

    // Update the user's password and clear the reset token
    update := bson.M{
        "$set": bson.M{"password": hashedPassword},
        "$unset": bson.M{"resetToken": "", "tokenExpiresAt": ""},
    }
    _, err = collection.UpdateOne(context.Background(), bson.M{"resetToken": requestBody.Token}, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to reset password"})
    }

    // Respond to the client
    return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Password has been reset successfully"})
}

func hashPassword(password string) string {
    // For simplicity, this function just returns the plain password. In production,
    // you should use a proper hashing method like bcrypt.
    return password
}
func getAllUsers(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")

    // Use Find() to get all records
    cursor, err := collection.Find(context.Background(), bson.M{})
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"status": "error", "message": "Could not fetch users"})
    }

    var rewards []bson.M
    if err := cursor.All(context.Background(), &rewards); err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"status": "error", "message": "Error while decoding users"})
    }

    return c.Status(http.StatusOK).JSON(rewards)
}

func transferData(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    user_id := c.Params("user_id")

    // Define a struct for the update payload
    var updatePayload Users // Use the Users struct for the update payload

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    // Debug: Log the user_id and updatePayload
    fmt.Printf("Updating user with ID: %s\n", user_id)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"user_id": user_id}
    update := bson.M{
        "$set": bson.M{
            "user_id":         updatePayload.UserId,
            "currentMl":       updatePayload.CurrentMl,
            "botLiv":          updatePayload.BotLiv,
            "totalMl":         updatePayload.TotalMl,
            "fillingLimit":    updatePayload.FillingLimit,
            "eventBot":        updatePayload.EventBot,
            "startFillingTime": updatePayload.StartFillingTime, // Store as time.Time
            "profileImg_link": updatePayload.ProfileImgLink,
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "User not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "User updated successfully!"})
}

func updateUserIdByEmail(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    email := c.Params("email")

    // Define a struct for the update payload
    var updatePayload struct {       
        UserId string `json:"user_id"`
    }

    // Parse the request body into the struct
    if err := c.BodyParser(&updatePayload); err != nil {
        return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
    }

    fmt.Printf("Updating water with ID: %s\n", email)
    fmt.Printf("Update payload: %+v\n", updatePayload)

    // Define the filter and update
    filter := bson.M{"email": email}
    update := bson.M{
        "$set": bson.M{
            "user_id": updatePayload.UserId, // Match the struct field name
        },
    }

    // Perform the update operation
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    // Check if a document was matched and updated
    if result.MatchedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "Water not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Water updated successfully!"})
}

type Users struct {
    UserId          string    `json:"user_id"`
    Uid             string    `json:"uid"`
    UserName        string    `json:"username"`
    Email           string    `json:"email"`
    CurrentMl       int       `json:"currentMl"`
    TotalMl         int       `json:"totalMl"`
    BotLiv          int       `json:"botLiv"`
    ProfileImgLink  string    `json:"profileImg_link"`
    StartFillingTime *time.Time `json:"startFillingTime"` // Use pointer for nullable field
    FillingLimit    int       `json:"fillingLimit"`
    CouponCheck     []string  `json:"couponCheck"`
    EventBot        int       `json:"eventBot"`
}


