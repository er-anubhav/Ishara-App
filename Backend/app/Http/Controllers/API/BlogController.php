<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Library\Beautify;
use App\Library\Structure;
use App\Models\Post;
use App\Models\Category;

class BlogController extends Controller
{
    use Structure;

    public function categories(Request $request){

        $categories =  Category::where('is_active', 'Yes')->select('id', 'name', 'icon')->orderBy('position', 'asc')->get();

        $beautify = new Beautify();
        $categories = $beautify->blog_categories($categories);
        array_unshift($categories, ['id' => 'All', 'name' => 'All', 'icon' => null]);
        return response()->json($this->structure(true, "Blog Categories", $categories), 200);
    }

    public function blogs(Request $request)
    {
        $table = Post::leftJoin('categories as c', 'c.id', 'posts.category')->where('posts.status', 'Active');

        if ($request->category && $request->category != 'All') {
            $table = $table->where('c.id', $request->category);
        }

        if ($request->search) {
            $table = $table->where('posts.heading', 'like', '%' . $request->search . '%');
            $table = $table->orWhereRaw('json_contains(posts.tags, \'["'.$request->search.'"]\')');
        }

        //Page Calculations.
        $data_records['pagination'] = true;
        $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
        $data_records['limit'] = request('limit') ? request('limit') : 6 ;
        $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

        //count the total lead data.
        $data_records['total_records'] = $table->count();

        $posts = $table->skip($data_records['start'])->take($data_records['limit'])
                    ->select('posts.id', 'posts.heading', 'posts.description', 'posts.image', 'posts.tags', 'posts.created_at', 'c.name as category_name')
                    ->orderBy('posts.id', 'desc')
                    ->get();


        if (count($posts) > 0) {

            $beautify = new Beautify();
            $posts = $beautify->blogs($posts);
            $data['data'] = $posts;
            $data['data_records'] = $data_records;
            return response()->json($this->structure(true, "Blogs found", $data), 200);
        }

        return response()->json($this->structure(false, "Blogs not found!"), 200);
    }

    public function blog_view(Request $request)
    {
        $post_id = isset($request->id) ? $request->id : 0 ;
        $post = Post::leftJoin('categories as c', 'c.id', 'posts.category')->where('posts.status', 'Active')->where('posts.id', $post_id)
                    ->orderBy('posts.id', 'desc')->select('posts.*', 'c.name as category_name')->get();

        if (count($post) > 0) {

            $beautify = new Beautify();
            $post = $beautify->blogs($post);
            return response()->json($this->structure(true, "Blog found", $post), 200);
        }

        return response()->json($this->structure(false, "Blog not found!"), 200);
    }

}
