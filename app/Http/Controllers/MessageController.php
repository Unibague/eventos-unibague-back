<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MessageController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(int $id)
    {
        $event = Event::findOrFail($id);
        $messages = DB::table('event_messages')
            ->where('event_id','=',$event->id)
            ->orderBy('created_at','desc')->get();
        return response()->json($messages);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request, string $id)
    {
        $messageContent = $request->input('message');
        $userId = $request->input('userId');
        try {
            Message::create(['content' => $messageContent,
                'posted_by' => $userId, 'event_id' => $id]);

            //Also set the has_unread_messages from users table to users associated with that email, to true

            // Find all users associated with the event
            $userIds = DB::table('restricted_event_users')
                ->where('event_id', $id)
                ->pluck('user_id'); // Get the user IDs as a collection

            // Update the has_unread_messages for these users
            DB::table('users')
                ->whereIn('id', $userIds)
                ->where('has_unread_messages', false)
                ->update(['has_unread_messages' => true]);

            return response()->json(['message'=> 'Message sent correctly']);
        } catch (\Exception $exception) {
            return response()->json(['message' => 'An error occurred when adding the message'], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(int $id)
    {

    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
