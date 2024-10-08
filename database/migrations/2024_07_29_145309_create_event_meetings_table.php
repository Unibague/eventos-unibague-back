<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('event_meetings', function (Blueprint $table) {
            $table->id();
            $table->string('internal_identifier');
            $table->string('name');
            $table->text('description');
            $table->string('location');
            $table->string('speaker');
            $table->string('start_date');
            $table->string('end_date');
            $table->text('online_link')->nullable();
            $table->foreignId('event_id')->constrained();
            $table->boolean('visible')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('event_meetings');
    }
};
