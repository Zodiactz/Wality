package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Define a MongoDB client variable
var client *mongo.Client

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

    // Create a new Fiber app
    app := fiber.New()

    // Define routes
    app.Post("/create", createPerson)
    app.Get("/users/:username", getPerson)
    app.Get("/userId/:user_id", getUserById)
    app.Get("/waterId/:waterId", getWaterById)
    app.Put("/update/:name", updatePerson)
    app.Delete("/delete/:name", deletePerson)
    app.Post("/updateUserWater/:user_id", updateUserWater)
    app.Post("/updateWaterStatus/:waterId", updateWaterStatus)

    // Start the server
    log.Fatal(app.Listen(":8080"))
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
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "userName not found!"})
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
func deletePerson(c *fiber.Ctx) error {
    collection := client.Database("Wality_DB").Collection("Users")
    name := c.Params("name")

    result, err := collection.DeleteOne(context.Background(), bson.M{"name": name})
    if err != nil {
        return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
    }

    if result.DeletedCount == 0 {
        return c.Status(http.StatusNotFound).JSON(fiber.Map{"status": "Person not found!"})
    }

    return c.Status(http.StatusOK).JSON(fiber.Map{"status": "Person deleted successfully!"})
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

    // Define a struct for the update payload
    var updatePayload struct {
        CurrentMl int `json:"currentMl"`
        BotLiv    int `json:"botLiv"`
        TotalMl   int `json:"totalMl"`  // Add TotalMl to the struct
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
            "currentMl": updatePayload.CurrentMl,
            "botLiv":    updatePayload.BotLiv,
            "totalMl":   updatePayload.TotalMl,  // Include TotalMl in the update
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

