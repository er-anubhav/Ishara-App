<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Library\Beautify;
use App\Library\Structure;
use App\Models\Post;

class BlogController extends Controller
{
    use Structure;

    public function blogs(Request $request)
    {
        $posts = Post::leftJoin('categories as c', 'c.id', 'posts.category')->where('posts.status', 'Active')
                            ->orderBy('posts.id', 'desc')->select('posts.*', 'c.name as category_name')->get();

        if ($posts) {

            $beautify = new Beautify();
            $posts = $beautify->blogs($posts);
            return response()->json($this->structure(true, "Blogs", $posts), 200);
        }

        return response()->json($this->structure(false, "Blogs not found!"), 200);
    }
}
