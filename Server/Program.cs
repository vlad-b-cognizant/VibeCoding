using Server.Repositories;
using Server.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register repositories and services
// Use JSON file repository for brainstorming (testing purposes)
builder.Services.AddScoped<IBrainstormingRepository, JsonFileBrainstormingRepository>();
builder.Services.AddScoped<IBrainstormingService, BrainstormingService>();

// Add CORS support for React Native client
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactNativeClient", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Enable CORS
app.UseCors("AllowReactNativeClient");

// Map controllers
app.MapControllers();

app.Run();
